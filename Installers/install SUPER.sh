#!/bin/bash

# Mathijs de Willigen
# Script is "AS IS" and will download Super from github and installs it.

output_folder="/private/tmp/super"
file="super"
url="https://raw.githubusercontent.com/Macjutsu/super/main/super"

echo "##################################"
echo "Running download SUPER Script..."

# Create tmp directory
if [ ! -d ${output_folder} ]; then
	echo "##################################"
	echo "Create super folder in /tmp"
	mkdir "${output_folder}"
	chmod 755 "${output_folder}"
else
	echo "##################################"
	echo "Found super folder"
fi

# Download super
echo "##################################"
echo "Download SUPER from Github..."
curl -s -o "${output_folder}/${file}" -L "${url}"

# Check version
superVERSION=$(awk -F '"' '/superVERSION=/ { print $2 }' ${output_folder}/${file})
echo "##################################"
echo "Downloaded SUPER Version: ${superVERSION}"
echo "##################################"

# Make script executable
echo "Change permissions..."
echo "##################################"
chmod +x "${output_folder}/${file}"

### Run super
echo "Run SUPER install..."
echo "##################################"
cd ${output_folder}
./${file}

# sleep
sleep 5 

# remove temp directory
echo "Run cleanup. /tmp/super deleted."
echo "##################################"
rm -Rf ${output_folder}