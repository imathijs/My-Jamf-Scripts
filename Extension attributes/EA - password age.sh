#!/bin/bash
## Returns the Age of the Macbook's local password in Days.

LOGGED_IN_USER=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! / loginwindows/ { print $3 }')

pwLastChangeEpoch=$(dscl . read /Users/"$LOGGED_IN_USER" accountPolicyData | sed -n '/passwordLastSetTime/{n;s@.*<real>\(.*\)</real>@\1@p;}' | sed s/\.[0-9,]*$//g)

TimeFormatted=$(date -jf %s $pwLastChangeEpoch +%F\ %T)

echo "Date last password change: $TimeFormatted"

echo "<result>$(( ( $(date +%s) - $pwLastChangeEpoch ) / 86400 )) days</results>"