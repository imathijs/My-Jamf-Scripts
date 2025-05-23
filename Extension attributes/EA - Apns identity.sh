#!/bin/sh

# This script checks if the Mac's APNS identity matches the one registered in Jamf Pro.
# It compares the current system topic with the expected identity.
# If they don't match, a warning is returned.

# Registered Jamf Pro APNS identity
identity="com.apple.mgmt.External.<identitycode>"

# Get computer APNS identity
topic=$(/System/Library/PrivateFrameworks/ApplePushService.framework/apsctl status | grep -m1 "com.apple.mgmt.External" | awk '{print $NF}')

# Checks value
if [[ "$identity" != "$topic" ]]; then
	echo "<result>Warning! APNS token does not match with Jamf Pro</result>"
else	
	echo "<result>APNS identity matches Jamf Pro</result>"
fi

