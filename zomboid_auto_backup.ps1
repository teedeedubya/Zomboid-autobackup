#Description:  This is a autobackup for Zomboid save files, It will backup as often as you configure inside of the task scheduler
#              I set mine to once every 10 minutes. 


# Retention controls how many snapshots you want to keep of your current sandbox session
# The higher this number is, the more diskspace yinz is gonna use 0_0
$Retention=10

# Function required for determining two things:
# is the player actually playing the game or are they just sitting at the load screen?
# which save they currently working out of?
# this is accomplished by discovering which save's "players.db" file is locked
function Test-FileLock {
  param (
    [parameter(Mandatory=$true)][string]$Path
  )

  $oFile = New-Object System.IO.FileInfo $Path

  if ((Test-Path -Path $Path) -eq $false) {
    return $false
  }

  try {
    $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

    if ($oStream) {
      $oStream.Close()
    }
    return $false
  } catch {
    # file is locked by a process.
    return $true
  }
}


#check if zomboid is running... no point in autosaving if it isn't running!
$StateOfZomboid = Get-Process ProjectZomboid* -ErrorAction SilentlyContinue


if( !$StateOfZomboid ) {
  write-output "zomboid is not running"
  exit

} elseif ( $StateOfZomboid ) {
  
  # project zomboid IS RUNNING... let's take a backup...
  write-output "zomg zomboid is RUUUUUNNNNNIIIINNNGGGG"
  $SavePath = "$env:USERPROFILE\Zomboid\Saves\Sandbox"
  $Saves = Get-ChildItem $SavePath -Directory | Sort-Object LastWriteTime -Descending
  $InUseSave=$false

  # Has the player loaded a save yet?
  foreach ( $Save in $Saves ){
    $FileLockStatus = Test-FileLock((Join-Path $Save.FullName "players.db")) 
    Write-Output $FileLockStatus

    if ( $FileLockStatus ) {
      # we found an in use save!@!@!@!!!!
      $InUseSave = $Save.Name
      break
    } 
  }

  if ( !$InUseSave ){
    #failed to find any in use save... I don't know which one to backup or which one to keep
    #is the player just sitting on the load screen :/
    write-output "no in use save detected"
    Exit
  }

  $Epoch = Get-Date -Date (Get-Date) -UFormat %s
  $Epoch = [Math]::Truncate($Epoch)
  $SplitInUseSave = $InUseSave.split("#")
 
  #BEGIN actually taking a backup..

  # is the player playing out of an autosave??
  if ( $InUseSave -like "*AUTOSAVE*" ){
    #yes, they are playing out of an autosave
    $NewAutoSave = (Join-Path $SavePath $SplitInUseSave[0]) + '#AUTOSAVE#' + $Epoch
 
  }else {
    #no, they are not playing out of an autosave
    $NewAutoSave = (Join-Path $SavePath $InUseSave) + '#AUTOSAVE#' + $Epoch    
  }

  Write-Output "creating $NewAutoSave"
  Copy-Item -Path (Join-Path $SavePath $InUseSave) -Destination $NewAutoSave -Recurse


  #Begin Autosave Rotation
  $AutoSaves = $Saves | Where-Object { $_.Name -match $SplitInUseSave[0] -and $_.Name -match "#AUTOSAVE#" -and  $_.Name -ne $InUseSave}
  $AutoSaveCount = ($AutoSaves | Measure-Object).Count

  if ( $AutoSaveCount -gt $Retention) {
    Write-Output "rotating backups"
    $OldestAutoSave = $autoSaves | select-object -Last 1
    Remove-Item $OldestAutoSave.FullName -Recurse -Force

  } else {
    Write-Output "no rotating backups as there are not enough autosaves"
  }

}
