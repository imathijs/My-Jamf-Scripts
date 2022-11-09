#!/bin/sh

# JAMF CLOUD TENANT URL
URL="https://<url>.jamfcloud.com/"

# USERNAME PASSWORD BASE64
APIHASH="<HASH>"

## Retrieve the authToken using the APIHASH
authToken=$(curl -sX POST "${URL}api/v1/auth/token" -H "accept: application/json" -H "Authorization: Basic ${APIHASH}")
## Retrieve the api_token using the authToken
api_token=$(/usr/bin/awk -F \" 'NR==2{print $4}' <<< "$authToken" | /usr/bin/xargs)

# GET PRESTAGE SCOPE
curl -sX GET "${URL}api/v2/computer-prestages/scope" -H "accept: application/json" -H "Authorization: Bearer $api_token" | json_pp
