#!/bin/bash

# VARIABLES
namecomputer=$(/usr/sbin/scutil --get ComputerName)
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
icon="SF=laptopcomputer"
dialogApp="/usr/local/bin/dialog"

title="Computer hernoemen mislukt"
message="Computernaam is niet automatisch aangepast. Controleer of deze Mac is verwerkt in de Jamf Pro Preload-Inventory en pas deze aan.\n\n 
Huidige computergevens:
* Computernaam: **$namecomputer**
* Serienummer: **$sn**\n
Ga door met onboarden, voer zelfstandig de computernaam in:"

dialogCMD="$dialogApp -p --title \"$title\" \
--icon \"$icon\" \
--message \"$message\" \
--messagefont "name=Arial,size=12" \
--small \
--button1text "Hernoem" \
--button2 \
--ontop \
--moveable \
--textfield \"Computernaam:\",prompt=\"Mac123\",regex='^[Mm][Aa][Cc].{3}$',regexerror=\"Naam mag maximaal 6 karakters bevatten en moet voldoen aan de volgende structuur: Mac[nummer] \""

computerName=$(eval "$dialogCMD" | awk -F " : " '{print $NF}')

if [[ $computerName == "" ]]; then
	echo "Aborting"
	exit 1
fi

scutil --set HostName "$computerName"
scutil --set LocalHostName "$computerName"
scutil --set ComputerName "$computerName"

# Run Jamf binary command to update inventory record with new computer name
/usr/local/bin/jamf recon -setComputerName "$computerName"

# Echo new computer name for logging
echo "Computer Name is now $computerName"

exit 0