#!/bin/bash
# remove_apps.sh
# Force‑quit and delete one or more macOS applications.
#
# Usage examples
#   1) Apps listed in the script itself : ./remove_apps.sh
#   2) Pass apps as arguments           : ./remove_apps.sh Bluesky.app Cleft.app ...

###############################################################################
# 1. Option A – apps listed inside the script
###############################################################################
APPS=(
  "Bluesky.app"
  "Cleft.app"
  "GarageBand.app"
  "MacWhisper.app"
  "VMware Horizon Client.app"
)

###############################################################################
# 2. Function to stop and remove a single app
###############################################################################
remove_app () {
  local APP_FULL_NAME="$1"
  local APP_NAME="${APP_FULL_NAME%.app}"        # strip .app
  local APP_PATH="/Applications/$APP_FULL_NAME"

  echo "⏹  Attempting to terminate processes for \"$APP_NAME\"..."
  # pkill gracefully; fall back to signal 9 only if needed
  pkill -x "$APP_NAME" 2>/dev/null || true

  if [ -d "$APP_PATH" ]; then
    echo "🗑  Removing: $APP_PATH"
    rm -rf "$APP_PATH"
    if [ $? -eq 0 ]; then
      echo "✅  $APP_FULL_NAME was removed successfully."
    else
      echo "⚠️  An error occurred while removing $APP_FULL_NAME."
    fi
  else
    echo "ℹ️  $APP_FULL_NAME not found in /Applications."
  fi
  echo "---------------------------------------------"
}

###############################################################################
# 3. Loop over all requested apps
###############################################################################
for APP in "${APPS[@]}"; do
   remove_app "$APP"
done
