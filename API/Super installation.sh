#!/bin/bash
#
# JAMF PRO SUPER INSTALLATION SCRIPT
# Mathijs de Willigen | Prowarehouse
# SCRIPT IS "AS IS" 
#
# Automated install of S.U.P.E.R into Jamf Pro
# Creates:
# - API user
# - Configuration Profile with PPPC
# - S.U.P.E.R and Uninstaller scripts
# - Policy
# 
# This does not set the scoping!
#
##################################
# JAMF PRO LOGIN
jamfURL="https://<url>.jamfcloud.com"
username="<login>"
password="<password>"

##################################
# SUPER API CREDENTIALS, PASSWORD WILL BE GENERATED
apiName="_superapi"

# GENERATE API PASSWORD
passCharacters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+=-"
passLenght=16
apiPassword=$(openssl rand -base64 48 | tr -dc "$passCharacters" | head -c "$passLenght")

##################################
# SUPER URL
super_main="https://raw.githubusercontent.com/Macjutsu/super/main"
script_url="${super_main}/super"

##################################
# BEARER TOKEN
encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

authToken=$( /usr/bin/curl "$jamfURL/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials" )

# parse authToken for token, omit expiration
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )

##################################
# FUNCTIONS

createAPIUSER() {
user_XML="
<account>
<id>-1</id>
<name>$apiName</name>
<directory_user>false</directory_user>
<full_name>SUPER API</full_name>
<email></email>
<email_address></email_address>
<password>$apiPassword</password>
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
--url ${jamfURL}/JSSResource/accounts/userid/0 \
--header "Content-Type: text/xml" \
--data "$user_XML"

}


createSCRIPT() {
	
scripts_SUPER="
super
superremove
"
for superoptions in ${scripts_SUPER[@]}; do
	
	case $superoptions in
		super)
		script_name="SUPER"
		file_name="${script_name}"
			parameters_script="<parameters>
	<parameter4>--jamf-account=apiuser</parameter4>
	<parameter5>--jamf-password=apipassword</parameter5>
	</parameters>"
		;;
		
		superremove)
		script_name="SUPER Remove"
		file_name="super_remove.sh"
		script_url=${super_main}/Super-Friends/Remove-super.sh
		;;
	esac
	
# SUPER URL
script_contents=$(curl -s "$script_url")
script_version=$(echo "$script_contents" | grep -o "superVERSION=\"[^\"]*\"" | cut -d'"' -f2)
escaped_script_contents=$(echo "$script_contents" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')

	if [ -n $script_version ]; then
		echo "Install SUPER version: $script_version"
	fi

script_XML="
<script>
	<id>-1</id>
	<name>$script_name</name>
	<category>None</category>
	<filename>$file_name</filename>
	<info/>
	<notes>$script_url</notes>
	<priority>After</priority>
	$parameters_script
	<os_requirements/>
	<script_contents>$escaped_script_contents</script_contents>
</script>"

# CREATE SCRIPT
curl --request POST \
--header "Authorization: Bearer $token" \
--url ${jamfURL}/JSSResource/scripts/id/0 \
--header "Content-Type: text/xml" \
--data "$script_XML"

done
	
}

createEA () {
	
   eaJAMF="
	ea_superstatus
	ea_superversion
	ea_downloaded
	"
	
	for ea in ${eaJAMF[@]}; do
		
	case $ea in
		ea_superstatus)
			eaname="SUPER status"
			eascript="${super_main}/Super-Friends/super-Status-Jamf-Pro-EA.sh"
			eadescription=""

		;;
		ea_superversion)
			eaname="SUPER version"
			eascript="${super_main}/Super-Friends/super-Installed-Version-Jamf-Pro-EA.sh"
			eadescription=""

		;;
		ea_downloaded)
			eaname="SUPER downloaded MacOS"
			eascript="${super_main}/Super-Friends/super-Downloaded-macOS-Jamf-Pro-EA.sh"
			eadescription=""

		;;
		*)
		echo "cant find what you're looking for"
	esac
		
	script_contents=$(curl -s "$eascript")
	escaped_script_contents=$(echo "$script_contents" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
		
	ea_XML="
	<computer_extension_attribute>
	<id>-1</id>
	<name>$eaname</name>
	<description>$eadescription</description>
	<data_type>String</data_type>
	<input_type>
	<type>script</type>
	<platform>Mac</platform>
	<script>$escaped_script_contents</script>
	</input_type>
	<inventory_display>Operating System</inventory_display>
	</computer_extension_attribute>"
		
	# CREATE EXTENSION ATTRIBUTE
	curl --request POST \
	--header "Authorization: Bearer $token" \
	--url ${jamfURL}/JSSResource/computerextensionattributes/id/0 \
	--header "Content-Type: text/xml" \
	--data "$ea_XML"
		
	done
		
}

createPROFILE() {
	
profile_XML="
<os_x_configuration_profile>
	<general>
		<id>-1</id>
		<name>Super</name>
		<description/>
		<site/>
		<category/>
		<distribution_method>Install Automatically</distribution_method>
		<user_removable>false</user_removable>
		<level>System</level>
		<uuid>C80363A6-83D4-4B31-AD0D-1F88B0A83B3F</uuid>
		<redeploy_on_update>Newly Assigned</redeploy_on_update>
		<payloads>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;!DOCTYPE plist PUBLIC &quot;-//Apple//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;
&lt;plist version=&quot;1&quot;&gt;&lt;dict&gt;&lt;key&gt;PayloadUUID&lt;/key&gt;&lt;string&gt;C80363A6-83D4-4B31-AD0D-1F88B0A83B3F&lt;/string&gt;&lt;key&gt;PayloadType&lt;/key&gt;&lt;string&gt;Configuration&lt;/string&gt;&lt;key&gt;PayloadOrganization&lt;/key&gt;&lt;string&gt;JAMF&lt;/string&gt;&lt;key&gt;PayloadIdentifier&lt;/key&gt;&lt;string&gt;C80363A6-83D4-4B31-AD0D-1F88B0A83B3F&lt;/string&gt;&lt;key&gt;PayloadDisplayName&lt;/key&gt;&lt;string&gt;Super&lt;/string&gt;&lt;key&gt;PayloadDescription&lt;/key&gt;&lt;string/&gt;&lt;key&gt;PayloadVersion&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;key&gt;PayloadEnabled&lt;/key&gt;&lt;true/&gt;&lt;key&gt;PayloadRemovalDisallowed&lt;/key&gt;&lt;true/&gt;&lt;key&gt;PayloadScope&lt;/key&gt;&lt;string&gt;System&lt;/string&gt;&lt;key&gt;PayloadContent&lt;/key&gt;&lt;array&gt;&lt;dict&gt;&lt;key&gt;PayloadUUID&lt;/key&gt;&lt;string&gt;39C0D0AB-1E15-45C4-9431-3C91C4EAFB7E&lt;/string&gt;&lt;key&gt;PayloadType&lt;/key&gt;&lt;string&gt;com.apple.TCC.configuration-profile-policy&lt;/string&gt;&lt;key&gt;PayloadOrganization&lt;/key&gt;&lt;string&gt;Macjutsu&lt;/string&gt;&lt;key&gt;PayloadIdentifier&lt;/key&gt;&lt;string&gt;39C0D0AB-1E15-45C4-9431-3C91C4EAFB7E&lt;/string&gt;&lt;key&gt;PayloadDisplayName&lt;/key&gt;&lt;string&gt;Privacy Preferences Policy Control&lt;/string&gt;&lt;key&gt;PayloadDescription&lt;/key&gt;&lt;string/&gt;&lt;key&gt;PayloadVersion&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;key&gt;PayloadEnabled&lt;/key&gt;&lt;true/&gt;&lt;key&gt;Services&lt;/key&gt;&lt;dict&gt;&lt;key&gt;SystemPolicySysAdminFiles&lt;/key&gt;&lt;array&gt;&lt;dict&gt;&lt;key&gt;Identifier&lt;/key&gt;&lt;string&gt;/usr/local/jamf/bin/jamf&lt;/string&gt;&lt;key&gt;CodeRequirement&lt;/key&gt;&lt;string&gt;identifier &quot;com.jamfsoftware.jamf&quot; and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = &quot;483DWKW443&quot;&lt;/string&gt;&lt;key&gt;IdentifierType&lt;/key&gt;&lt;string&gt;path&lt;/string&gt;&lt;key&gt;StaticCode&lt;/key&gt;&lt;integer&gt;0&lt;/integer&gt;&lt;key&gt;Allowed&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;/dict&gt;&lt;dict&gt;&lt;key&gt;Identifier&lt;/key&gt;&lt;string&gt;com.jamf.management.Jamf&lt;/string&gt;&lt;key&gt;CodeRequirement&lt;/key&gt;&lt;string&gt;identifier &quot;com.jamf.management.Jamf&quot; and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = &quot;483DWKW443&quot;&lt;/string&gt;&lt;key&gt;IdentifierType&lt;/key&gt;&lt;string&gt;bundleID&lt;/string&gt;&lt;key&gt;StaticCode&lt;/key&gt;&lt;integer&gt;0&lt;/integer&gt;&lt;key&gt;Allowed&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;/dict&gt;&lt;/array&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;dict&gt;&lt;key&gt;PayloadDisplayName&lt;/key&gt;&lt;string&gt;Custom Settings&lt;/string&gt;&lt;key&gt;PayloadIdentifier&lt;/key&gt;&lt;string&gt;4873DABA-5F5C-4708-AF5C-3D396AEFCB17&lt;/string&gt;&lt;key&gt;PayloadOrganization&lt;/key&gt;&lt;string&gt;JAMF Software&lt;/string&gt;&lt;key&gt;PayloadType&lt;/key&gt;&lt;string&gt;com.apple.ManagedClient.preferences&lt;/string&gt;&lt;key&gt;PayloadUUID&lt;/key&gt;&lt;string&gt;4873DABA-5F5C-4708-AF5C-3D396AEFCB17&lt;/string&gt;&lt;key&gt;PayloadVersion&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;key&gt;PayloadContent&lt;/key&gt;&lt;dict&gt;&lt;key&gt;com.apple.systempreferences&lt;/key&gt;&lt;dict&gt;&lt;key&gt;Forced&lt;/key&gt;&lt;array&gt;&lt;dict&gt;&lt;key&gt;mcx_preference_settings&lt;/key&gt;&lt;dict&gt;&lt;key&gt;AttentionPrefBundleIDs&lt;/key&gt;&lt;integer&gt;0&lt;/integer&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;/array&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;dict&gt;&lt;key&gt;PayloadDisplayName&lt;/key&gt;&lt;string&gt;Custom Settings&lt;/string&gt;&lt;key&gt;PayloadIdentifier&lt;/key&gt;&lt;string&gt;6E6CA096-5553-4D5F-9424-D02EA1DF0B5F&lt;/string&gt;&lt;key&gt;PayloadOrganization&lt;/key&gt;&lt;string&gt;JAMF Software&lt;/string&gt;&lt;key&gt;PayloadType&lt;/key&gt;&lt;string&gt;com.apple.ManagedClient.preferences&lt;/string&gt;&lt;key&gt;PayloadUUID&lt;/key&gt;&lt;string&gt;6E6CA096-5553-4D5F-9424-D02EA1DF0B5F&lt;/string&gt;&lt;key&gt;PayloadVersion&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;key&gt;PayloadContent&lt;/key&gt;&lt;dict&gt;&lt;key&gt;com.macjutsu.super&lt;/key&gt;&lt;dict&gt;&lt;key&gt;Forced&lt;/key&gt;&lt;array&gt;&lt;dict&gt;&lt;key&gt;mcx_preference_settings&lt;/key&gt;&lt;dict&gt;&lt;key&gt;AllowRSRUpdates&lt;/key&gt;&lt;true/&gt;&lt;key&gt;AllowUpgrade&lt;/key&gt;&lt;true/&gt;&lt;key&gt;DefaultDefer&lt;/key&gt;&lt;string&gt;X&lt;/string&gt;&lt;key&gt;DisplayIcon&lt;/key&gt;&lt;string&gt;/Applications/Self Service.app/Contents/Resources/AppIcon.icns&lt;/string&gt;&lt;key&gt;DisplayRedraw&lt;/key&gt;&lt;string&gt;900&lt;/string&gt;&lt;key&gt;EnforceNonSystemUpdates&lt;/key&gt;&lt;true/&gt;&lt;key&gt;FocusDefer&lt;/key&gt;&lt;string&gt;X&lt;/string&gt;&lt;key&gt;ForceRestart&lt;/key&gt;&lt;false/&gt;&lt;key&gt;HardDays&lt;/key&gt;&lt;string&gt;30&lt;/string&gt;&lt;key&gt;IconSizeIbm&lt;/key&gt;&lt;string&gt;128&lt;/string&gt;&lt;key&gt;IconSizeJamf&lt;/key&gt;&lt;string&gt;128&lt;/string&gt;&lt;key&gt;JamfProID&lt;/key&gt;&lt;string&gt;\$JSSID&lt;/string&gt;&lt;key&gt;MenuDefer&lt;/key&gt;&lt;string&gt;900,1800,3600,10800,18000&lt;/string&gt;&lt;key&gt;RecheckDefer&lt;/key&gt;&lt;string&gt;X&lt;/string&gt;&lt;key&gt;SkipUpdates&lt;/key&gt;&lt;false/&gt;&lt;key&gt;SoftDays&lt;/key&gt;&lt;string&gt;15&lt;/string&gt;&lt;key&gt;TargetUpgrade&lt;/key&gt;&lt;string&gt;13&lt;/string&gt;&lt;key&gt;TestMode&lt;/key&gt;&lt;false/&gt;&lt;key&gt;TestModeTimeout&lt;/key&gt;&lt;string&gt;15&lt;/string&gt;&lt;key&gt;UserAuthMDMFailover&lt;/key&gt;&lt;string&gt;ALWAYS&lt;/string&gt;&lt;key&gt;VerboseMode&lt;/key&gt;&lt;false/&gt;&lt;key&gt;ZeroDay&lt;/key&gt;&lt;string&gt;X&lt;/string&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;/array&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;/dict&gt;&lt;dict&gt;&lt;key&gt;PayloadDisplayName&lt;/key&gt;&lt;string&gt;Notifications Payload&lt;/string&gt;&lt;key&gt;PayloadIdentifier&lt;/key&gt;&lt;string&gt;55E169D9-E16A-40F3-AAE8-B816D296F042&lt;/string&gt;&lt;key&gt;PayloadOrganization&lt;/key&gt;&lt;string&gt;JAMF Software&lt;/string&gt;&lt;key&gt;PayloadType&lt;/key&gt;&lt;string&gt;com.apple.notificationsettings&lt;/string&gt;&lt;key&gt;PayloadUUID&lt;/key&gt;&lt;string&gt;D126680A-604A-428C-A08F-C1CDE319AC22&lt;/string&gt;&lt;key&gt;PayloadVersion&lt;/key&gt;&lt;integer&gt;1&lt;/integer&gt;&lt;key&gt;NotificationSettings&lt;/key&gt;&lt;array&gt;&lt;dict&gt;&lt;key&gt;BundleIdentifier&lt;/key&gt;&lt;string&gt;_system_center_:com.apple.softwareupdatenotification&lt;/string&gt;&lt;key&gt;CriticalAlertEnabled&lt;/key&gt;&lt;false/&gt;&lt;key&gt;NotificationsEnabled&lt;/key&gt;&lt;false/&gt;&lt;/dict&gt;&lt;/array&gt;&lt;/dict&gt;&lt;/array&gt;&lt;/dict&gt;&lt;/plist&gt;</payloads>
	</general>
	<scope>
		<all_computers>false</all_computers>
		<all_jss_users>false</all_jss_users>
		<computers/>
		<buildings/>
		<departments/>
		<computer_groups/>
		<jss_users/>
		<jss_user_groups/>
		<limitations>
			<users/>
			<user_groups/>
			<network_segments/>
			<ibeacons/>
		</limitations>
		<exclusions>
			<computers/>
			<buildings/>
			<departments/>
			<computer_groups/>
			<users/>
			<user_groups/>
			<network_segments/>
			<ibeacons/>
			<jss_users/>
			<jss_user_groups/>
		</exclusions>
	</scope>
	<self_service>
		<self_service_display_name>Super</self_service_display_name>
		<install_button_text>Install</install_button_text>
		<self_service_description/>
		<force_users_to_view_description>false</force_users_to_view_description>
		<security>
			<removal_disallowed>Never</removal_disallowed>
		</security>
		<self_service_icon/>
		<feature_on_main_page>false</feature_on_main_page>
		<self_service_categories/>
		<notification>false</notification>
		<notification>Self Service</notification>
		<notification_subject/>
		<notification_message/>
	</self_service>
</os_x_configuration_profile>"

# CREATE PROFILE
curl --request POST \
--header "Authorization: Bearer $token" \
--url ${jamfURL}/JSSResource/osxconfigurationprofiles/id/0 \
--header "Content-Type: text/xml" \
--data "$profile_XML"

}

createPOLICY() {
	
	# GET SCRIPT ID
	
	scriptid_xml=$(curl --request GET \
	--header "Authorization: Bearer $token" \
	--url ${jamfURL}/JSSResource/scripts \
	--silent \
	--header "Content-Type: text/xml")
	
	script_id=$(echo "$scriptid_xml" | xmllint --xpath "//script[name='SUPER']/id/text()" - )
	
	
policy_XML="
<policy>
	<general>
		<name>SUPER</name>
		<enabled>true</enabled>
		<trigger>super</trigger>
		<trigger_checkin>true</trigger_checkin>
		<trigger_enrollment_complete>false</trigger_enrollment_complete>
		<trigger_login>false</trigger_login>
		<trigger_logout>false</trigger_logout>
		<trigger_network_state_changed>false</trigger_network_state_changed>
		<trigger_startup>false</trigger_startup>
		<trigger_other>super</trigger_other>
		<frequency>Once every week</frequency>
		<location_user_only>false</location_user_only>
		<target_drive>/</target_drive>
		<offline>false</offline>
		<category>
			<id>-1</id>
			<name>Unknown</name>
		</category>
		<network_limitations>
			<minimum_network_connection>No Minimum</minimum_network_connection>
			<any_ip_address>true</any_ip_address>
		</network_limitations>
		<network_requirements>Any</network_requirements>
		<site>
			<id>-1</id>
			<name>None</name>
		</site>
	</general>
	<scope/>
	<self_service/>
	<package_configuration/>
	<scripts>
	<size>1</size>
	<script>
	<id>$script_id</id>
	<name>SUPER</name>
	<priority>After</priority>
	<parameter4>--jamf-account=$apiName</parameter4>
	<parameter5>--jamf-password=$apiPassword</parameter5>
	</script>
	</scripts>
	<printers/>
	<dock_items/>
	<account_maintenance/>
	<reboot/>
	<maintenance/>
	<files_processes/>
	<user_interaction/>
	<disk_encryption/>
</policy>"
	
	# CREATE PROFILE
	curl --request POST \
	--header "Authorization: Bearer $token" \
	--url ${jamfURL}/JSSResource/policies/id/0 \
	--header "Content-Type: text/xml" \
	--data "$policy_XML"
	
}

##################################
# RUN FUNCTIONS

createAPIUSER
createSCRIPT
createPROFILE
createEA
createPOLICY