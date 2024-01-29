#!/bin/bash
#
# Rename computer based on pre-inventory asset-tag.
# The script also verifies whether the correct criteria are being used. The criteria must consist of "Mac" followed by three numerical characters.
# Mathijs de Willigen 

# BEARER TOKEN #####################################################################
client_id="$4"
client_secret="$5"
jamfURL="https://<url>.jamfcloud.com"
tenant=$(echo "$jamfURL" | sed -e 's|^[^/]*//\([^/\.]*\).*|\1|')
capitalized_tenant="$(tr '[:lower:]' '[:upper:]' <<< ${tenant:0:1})${tenant:1}"

authToken=$( /usr/bin/curl "$jamfURL/api/oauth/token" \
--silent \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode "client_id=${client_id}" \
--data-urlencode "grant_type=client_credentials" \
--data-urlencode "client_secret=${client_secret}" )

# PARSE AUTHTOKEN FOR TOKEN, OMIT EXPIRATION
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )

# GET DEVICE SERIAL NUMBER
serialNumber="$(ioreg -l | grep IOPlatformSerialNumber | sed -e 's/.*\"\(.*\)\"/\1/')"

echo "Computerserial is: $serialNumber"

# GET ASSET FROM JAMF PRO
assetTag=$(/usr/bin/curl -H "Accept: text/xml" -H "Authorization: Bearer $token" -s "$jamfURL/JSSResource/computers/serialnumber/$serialNumber/subset/general" | xmllint --format - 2>/dev/null | awk -F'>|<' '/<asset_tag>/{print $3}')

echo "Assettag is: $assetTag"

# VALIDATE CRITERIA "Mac123"
if [[ $assetTag =~ ^[Mm][Aa][Cc].{3}$ ]]; then
	
    # SET COMPUTERNAME, HOSTNAME, LOCALHOSTNAME
	/usr/sbin/scutil --set HostName "$assetTag"
	/usr/sbin/scutil --set LocalHostName "$assetTag"
	/usr/sbin/scutil --set ComputerName "$assetTag" 
    
    echo "Computer renamed to: $assetTag"
	
else

	echo "Asset Tag does not meet the specified criteria. Please check serialnumber and assettag in Preload-Inventory"
    exit 1

fi

sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "$assetTag"

exit 0