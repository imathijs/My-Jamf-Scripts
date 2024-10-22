#!/bin/bash

# Jamf Remote High on CPU?, reinstall

# uninstall
"/Library/Application Support/JAMF/Remote Assist/jamfRemoteAssistLauncher" /operation=connector.uninstall

# install
/usr/sbin/installer -pkg "/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/JamfDaemon.app/Contents/Resources/JamfRemoteAssist.pkg" -target /

