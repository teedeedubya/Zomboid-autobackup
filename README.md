# Zomboid-autobackup
Powershell script to add autosave functionality to Zomboid singleplayer

meant to be executed via Microsoft's scheduler.

#issues:
this can use a ton of space if you have a ton of mods.  So if you've got a kazillion saves due to you dying all the time..
1. eventually, you'll run into the performance issues with this script because it has to iterate over every backup to infer which save needs to be backed up.
2. Any indivdual game will only have 10 versions of itself BUT if you load from an autosave...that is considered a seperate game. It will eventually generate its own 10 backups while leaving the 10 autosaves intact from the orginal.  This is a Good and a Bad thing.

Author: Tony Welder
Email: tony.wvoip@gmail.com

Use at your own risk.  best to test the thing before you rely on it.  I can tell you with 100% certainty it works well for me :).
