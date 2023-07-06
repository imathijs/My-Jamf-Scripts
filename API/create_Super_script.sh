#!/bin/bash

# CREATE USER FOR SUPER
URL="https://<url>.jamfcloud.com"
username="<login>"
password="<password>"

encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

authToken=$( /usr/bin/curl "$URL/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials" )

# parse authToken for token, omit expiration
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )


# SUPER URL
script_url="https://raw.githubusercontent.com/Macjutsu/super/main/super"
script_contents=$(curl -s "$script_url")
escaped_script_contents=$(echo "$script_contents" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')

scriptJAMF="
<script>
	<id>-1</id>
	<name>Super</name>
	<category>None</category>
	<filename>Super</filename>
	<info/>
	<notes>$script_url</notes>
	<priority>After</priority>
	<parameters>
	<parameter4>--jamf-account=apiuser</parameter4>
	<parameter5>--jamf-password=apipassword</parameter5>
	<parameter6>--reset-super</parameter6>
	</parameters>
	<os_requirements/>
	<script_contents>$escaped_script_contents</script_contents>
</script>"

# CREATE SCRIPT
curl --request POST \
--header "Authorization: Bearer $token" \
--url ${URL}/JSSResource/scripts/id/0 \
--header "Content-Type: text/xml" \
--data "$scriptJAMF"
