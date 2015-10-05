#!/bin/sh
# Try to fix Time Machine (and Spotlight)
# Must run this script as root
#
# <http://apple.stackexchange.com/questions/65486>

TimeMachineDrive='/Volumes/My Passport Studio'

# (1) Turn off Spotlight and TimeMachine
launchctl unload -w \
	"/System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
# TODO: how to turn off TM from commandline?


# (2) delete all Spotlight indexes
rm -rf \
	"/.Spotlight-V100/Store-V1" \
	"/.Spotlight-V100/Store-V2" \
	"/.Spotlight-V100/VolumeConfiguration.plist"

rm -rf \
	"$TimeMachineDrive/.Spotlight-V100/Store-V1" \
	"$TimeMachineDrive/.Spotlight-V100/Store-V2" \
	"$TimeMachineDrive/.Spotlight-V100/VolumeConfiguration.plist"


# (3) delete some other stuff (what exactly?)
rm -rf /var/folders/*


# (4) delete the partial TM backup
# Have to do this by moving it to the trash and then emptying trash
# Trying to delete TM backups with rm can corrupt things!
# N.B., can't just do `mv ... ~/.Trash` either since owner issues and being on a different volume
# doing `mv ... ~/.Trash` will actually move it to $TimeMachineFrive/.Trashes/$UID/
#
# TODO: how to empty from the commandline?
# <https://support.apple.com/en-us/HT201583>
#chflags -R nouchg ~/.Trash/*


# (5) Reboot --- Must do everything else manually
#reboot

# (6) Restart Spotlight
#launchctl load -w \
#	"/System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
#mdutil -i on -E /
# N.B., this will return quickly because it does it in the background/daemon


# (7) After that (actually) finishes, restart TimeMachine
# To see what files TM is having troubles with, use:
#opensnoop -n mdworker
