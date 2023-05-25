#!/bin/bash

# UNINSTALL NUDGE

# CHECK IF NUDGE IS RUNNING AND KILL IT
/usr/bin/pgrep -i Nudge | /usr/bin/xargs kill

# REMOVE NUDGE
rm -Rf /Applications/Utilities/Nudge.app

exit 0
