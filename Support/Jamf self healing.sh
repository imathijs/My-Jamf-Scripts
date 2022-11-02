#!/bin/sh
## postinstall
#
# JAMF BINARY SELF-HEAL
#
# Mathijs de Willigen
# Script is inspirated by modtitan:
# https://www.modtitan.com/2022/02/jamf-binary-self-heal-with-jamf-api.html

# DEBUG MODE (0 = FALSE / 1 = TRUE)
DEBUG=1

# FIND INTERNAL SERIALNUMBER
if [ $DEBUG = 0 ]; then
	SERIALCOMP=$(ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | tr -d '"')
else 
	#
	SERIALCOMP="<serial>"
fi

# JAMF CLOUD URL
URL="https://<url>.jamfcloud.com/"

# USERNAME PASSWORD BASE64
APIHASH="<hash>"

## Retrieve the authToken using the APIHASH
authToken=$(curl -sX POST "${URL}api/v1/auth/token" -H "accept: application/json" -H "Authorization: Basic ${APIHASH}")
## Retrieve the api_token using the authToken
api_token=$(/usr/bin/awk -F \" 'NR==2{print $4}' <<< "$authToken" | /usr/bin/xargs)

# GET JAMF COMPUTER ID RECORD
JAMFID=$(curl -sX GET "${URL}/JSSResource/computers/serialnumber/${SERIALCOMP}" -H "accept: application/xml" -H "accept: application/json" -H "Authorization: Bearer $api_token" | xmllint --xpath '/computer/general/id' - | tr -d '</id>' ​)

echo "###############################"
echo "Start Re-deploy ---------------"
echo "SerialNumber Mac: ${SERIALCOMP}"
echo "JamfID: ${JAMFID}"
echo "###############################"

# REDEPLOY IN JAMF PRO
if [ $DEBUG = 0 ]; then
	curl -X POST "${URL}api/v1/jamf-management-framework/redeploy/${JAMFID}" -H "accept: application/json" -H "Authorization: Bearer $api_token"
else
	echo "curl -X POST ${URL}api/v1/jamf-management-framework/redeploy/${JAMFID}"
fi

