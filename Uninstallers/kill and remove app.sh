#!/bin/bash
# This script forcefully terminates a running macOS application and then removes it from the /Applications directory.
# It takes the full application name (e.g., "AppName.app") as the fourth script argument ($4).
# The script extracts the base name, finds the process ID (PID), kills the process, and deletes the app bundle.


# kill app
APP_FULL_NAME="$4"
APP_NAME=$(basename "$APP_FULL_NAME" .app)
echo "App name without .app: $APP_NAME"

PID=$(ps axc | grep "$APP_NAME" | awk '{print $1}')

echo "$PID"

kill -9 ${PID}

# Path to the application
APP_PATH="/Applications/$4"

# Check if the application exists
if [ -d "$APP_PATH" ]; then
	echo "Application found: $APP_PATH"
	echo "Removing..."
	# Remove the application
	rm -rf "$APP_PATH"
	if [ $? -eq 0 ]; then
		echo "Application successfully removed."
	else
		echo "Error occurred while removing the application."
	fi
else
	echo "Application not found: $APP_PATH"
fi
