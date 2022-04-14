#!/bin/zsh
# open /Applications/ClickShare at login

APPPATH="/Applications/ClickShare.app"

LAUNCHAGENT=/Library/LaunchAgents/com.launch.ClickShare.app.plist

LAUNCHAGENTNAME=$(LAUNCHAGENT | awk -F"/" '{print $NF}' | rev | cut -f 2- -d '.' | rev)

/usr/libexec/PlistBuddy -c "Add :Label string $LAUNCHAGENTNAME" $LAUNCHAGENT​
/usr/libexec/PlistBuddy -c "Add :RunAtLoad bool 1" $LAUNCHAGENT​
/usr/libexec/PlistBuddy -c "Add :ProgramArguments array" $LAUNCHAGENT​
/usr/libexec/PlistBuddy -c "Add :ProgramArguments: string $APPPATH" $LAUNCHAGENT​