#!/bin/bash

#Delete Sophos Keychain
sudo rm /Library/Sophos\ Anti-Virus/SophosSecure.keychain

#Disable Sophos' tamper protection
sudo defaults write /Library/Preferences/com.sophos.sav TamperProtectionEnabled -bool false

#Changes Directory
cd /Library/Application\ Support/Sophos/saas/Installer.app/Contents/MacOS/tools/

#Execute Sophos uninstaller
sudo ./InstallationDeployer --remove