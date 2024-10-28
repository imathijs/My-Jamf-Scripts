#!/bin/bash

select_environment() {
  # Prompt the user for the company name to determine the Jamf Pro environment
  read -p "Enter the name for the Jamf Pro environment: " company_name
  
  # Construct the Jamf Pro URL based on the entered company name
  jamfProURL="https://${company_name}.jamfcloud.com"
  service_name="JamfReview-$company_name"
  
  echo "Jamf Pro environment selected: $jamfProURL"
  
  # Check if credentials exist in the keychain for the selected environment
    existing_password=$(security find-generic-password -s "$service_name" -w 2>/dev/null)
  
  if [ $? -eq 0 ]; then
    echo "Credentials found in the keychain. Logging in..."
    keychain-use
  else
    echo "Credentials not found in the keychain. Please add them first."
    keychain-add
  fi
}

keychain-add() {
  # Prompt the user for the account name and password
  read -p "Enter the account name: " account_name
  read -s -p "Enter the password: " password
  echo
  
  # Check if the key already exists; if so, delete it first
  existing_password=$(security find-generic-password -a "$account_name" -s "$service_name" -w 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "Deleting existing item in keychain..."
    security delete-generic-password -a "$account_name" -s "$service_name"
  fi
  
  # Add the account to the login keychain
  security add-generic-password -a "$account_name" -s "$service_name" -w "$password" -U
  
  # Check if the entry was successful
  if [ $? -eq 0 ]; then
    echo "Credentials successfully saved in the login keychain."
  else
    echo "An error occurred while saving the credentials."
  fi
}

keychain-use() {
  # Retrieve the username and password from the Keychain for the selected environment
  
  # Haal het volledige Keychain-item op
  keychain_item=$(security find-generic-password -s "$service_name" -g 2>&1)
  
  # Haal de gebruikersnaam (accountnaam) en wachtwoord eruit
  username=$(echo "$keychain_item" | grep "acct" | cut -d '"' -f 4)
  password=$(echo "$keychain_item" | grep "password" | cut -d '"' -f 2)
  
  # Controleer of beide waarden succesvol zijn opgehaald
  if [ -n "$username" ] && [ -n "$password" ]; then
    echo "Username: $username"
    echo "Password: $password"
  else
    echo "Could not retrieve the username and/or password from the Keychain."
  fi
  

  # Example: Authenticate with Jamf Pro using the retrieved credentials (Replace with actual login command)
  echo "Logging into Jamf Pro at $jamfProURL with username $username."
  
  # Here you can add a command to use the Bearer token, API request, etc., with $username and $password.
}

# Run the function to select the environment and login if credentials exist

select_environment