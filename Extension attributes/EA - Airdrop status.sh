#!/bin/bash

# Returns the current status of AirDrop
loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
airDropStatus=$(defaults read /Users/$loggedInUser/Library/Preferences/com.apple.sharingd.plist DiscoverableMode)
echo "<result>$airDropStatus</result>"
exit 0