#!/bin/bash

# GET VERSION BUILD NUMBER

if [ -d "/Applications/Pulse Secure.app" ]; then
	
BUILD="/Applications/Pulse Secure.app/Contents/Library/SystemExtensions/net.pulsesecure.firewall.systemextension.systemextension/Contents/Info.plist"
PULSE=$(defaults read "$BUILD" CFBundleVersion)

	echo "<result>$PULSE</result>"

else 
	
	echo "<result>Pulse not installed</result>"

fi

exit 0
