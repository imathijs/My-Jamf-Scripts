#!/bin/bash

# Replace these variables with your desired account name and password

account_name=""
password=""
service_name=""

keychain-add() {
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

keychain-get() {
  
  # Define the variables for the account name and service name as used when storing in the Keychain
  account_name="mathijs"
  service_name="test login"
  
  # Retrieve the username and password from the Keychain
  username=$(security find-generic-password -a "$account_name" -s "$service_name" -w 2>/dev/null)
  password=$(security find-generic-password -a "$account_name" -s "$service_name" -w 2>/dev/null)
  
  # Check if retrieval was successful
  if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Could not find the credentials in the Keychain."
    exit 1
  fi
  
}