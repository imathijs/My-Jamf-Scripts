#!/bin/zsh
#
# REMOVES DEFAULT MAC APPS
#
 
# Remove Numbers app
find /Applications -name Numbers.app -type d -exec rm -r {} +

# Remove Pages app
find /Applications -name Pages.app -type d -exec rm -r {} +

# Remove Keynote app
find /Applications -name Keynote.app -type d -exec rm -r {} +

# Remove Garage app
find /Applications -name GarageBand.app -type d -exec rm -r {} +

# Remove GarageBand Library
find "/Library/Application Support" -name GarageBand -type d -exec rm -r {} +

# Remove Logic Library
find "/Library/Application Support" -name Logic -type d -exec rm -r {} +

# Remove iMovie app
find /Applications -name iMovie.app -type d -exec rm -r {} +


exit 0