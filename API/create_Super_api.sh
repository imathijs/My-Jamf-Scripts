#!/bin/bash

# CREATE USER FOR SUPER

URL="https://<url>.jamfcloud.com"
username="<login>"
password="<password>"
apiname="<name>"
apipassword="<password>"

encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

authToken=$( /usr/bin/curl "$URL/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials" )

# parse authToken for token, omit expiration
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )


userDATA="
<account>
<id>-1</id>
<name>$apiname</name>
<directory_user>false</directory_user>
<full_name>SUPER API</full_name>
<email></email>
<email_address></email_address>
<password>$apipassword</password>
<enabled>Enabled</enabled>
<force_password_change>false</force_password_change>
<access_level>Full Access</access_level>
<privilege_set>Custom</privilege_set>
<privileges>
<jss_objects>
<privilege>Create Computers</privilege>
<privilege>Read Computers</privilege>
<privilege>Create Managed Software Update Plans</privilege>
<privilege>Read Managed Software Update Plans</privilege>
<privilege>Update Managed Software Update Plans</privilege>
</jss_objects>
<jss_settings></jss_settings>
<jss_actions>
<privilege>Send Computer Remote Command to Download and Install OS X Update</privilege>
</jss_actions>
<casper_admin></casper_admin>
</privileges>
</account>
"

# CREATE USER
curl --request POST \
--header "Authorization: Bearer $token" \
--url ${URL}/JSSResource/accounts/userid/0 \
--header "Content-Type: text/xml" \
--data "$userDATA"

## READ USERS
#curl --request GET \
#--header "Authorization: Bearer $token" \
#--url "${URL}/JSSResource/accounts" \
#--header 'accept: application/json'