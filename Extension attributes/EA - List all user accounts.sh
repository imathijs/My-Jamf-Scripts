#!/bin/bash

# Set the minimum UID value for self-created users
MIN_UID=501

# Retrieve all user accounts
users=$(dscl . -list /Users | grep -v '^_' | while read user; do
	uid=$(dscl . -read "/Users/$user" UniqueID | awk '{print $2}')
	if [ $uid -ge $MIN_UID ]; then
		echo "$user"
	fi
done)

# Print the list of self-created users
echo "<result>$users</result>"
