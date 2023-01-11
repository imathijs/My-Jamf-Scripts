#!/bin/bash

WAITINGROOM="/Library/Application Support/JAMF/Waiting Room"

if [[ -d "$WAITINGROOM" ]]; then

  WAITINGSPACE=$(du -sg "$WAITINGROOM" | awk '{print $1}')
  
  echo "<result>$WAITINGSPACE</result>"

else

  echo "<result>0</result>"

fi