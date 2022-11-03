#!/bin/bash
## Returns the Age of the Mac local password in Days.

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! / loginwindows/ { print $3 }' )

pwLastChangeEpoch=$(dscl . read /Users/"$currentUser" accountPolicyData | sed -n '/passwordLastSetTime/{n;s@.*<real>\(.*\)</real>@\1@p;}' | sed s/\.[0-9,]*$//g)

TimeFormatted=$(date -jf %s $pwLastChangeEpoch +%F)

days=$(echo "$((($(date +%s)-${pwLastChangeEpoch})/(3600*24))) days ago")

echo "<result>$TimeFormatted - $days</result>"


