#!/bin/bash

# CHECKS IF MICROSOFT APPS ARE INSTALLED BY CDN OR APPSTORE

msapps=(
	"/Applications/Microsoft Word.app"
	"/Applications/Microsoft Excel.app"
	"/Applications/Microsoft Outlook.app"
	"/Applications/Microsoft Powerpoint.app"
	"/Applications/Microsoft Edge.app"
	"/Applications/Microsoft Teams.app"
	"/Applications/OneDrive.app"
	"/Applications/Microsoft Remote Desktop.app"
)

echo "<result>"	
for app in "${msapps[@]}"; do
	
if [ -e "$app/Contents/_MASReceipt" ]; then
	VPPCheck=$(mdls "$app" | awk '/kMDItemAppStoreReceiptIsVPPLicensed/ {print $3}')
	if [ $VPPCheck -eq 1 ]; then
		echo "$app > MAS_VPP"
	else
		echo "$app > MAS_Personal"
	fi
else
	if [ -e "$app" ]; then
		echo "$app > CDN"
	else
		echo "$app > NOT INSTALLED"
	fi
fi

done
echo "</result>"



