#!/bin/bash

# Check if Homebrew is installed via command
if command -v brew &> /dev/null; then
	brew_status="Installed"
else
	brew_status="Not Installed"
fi

# Combine both results
echo "<result>$brew_status</result>"