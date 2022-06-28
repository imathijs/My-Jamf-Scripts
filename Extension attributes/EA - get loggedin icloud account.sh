#!/bin/zsh

# GET CURRENT USER
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! / loginwindows/ { print $3 }' )

# FILE
MobileMe=/Users/$currentUser/Library/Preferences/MobileMeAccounts.plist

# GET ICLOUD ACCOUNT
iCloud=$( defaults read $MobileMe Accounts | grep AccountID | cut -d '"' -f 2 )

# CHECK IF FILE EXIST, IF NOT THEN EXIT
if [ ! -e $MobileMe ]; then
    echo "<result></result>"
	exit 0
fi

echo "<result>$iCloud</result>"

exit 0

