#!/bin/zsh

# Installing in a hierarchical manner
# Mathijs de Willigen | Prowarehouse

jamfevent () {
	
	jamfrun=$(which jamf)
	$jamfrun policy -event "$1"
	
}

if [[ ! -f '/Library/Application Support/JAMF/.onboardingcomplete' ]]; then

	jamfevent rename
	jamfevent sym
	jamfevent onboardcomplete

fi

exit 0



