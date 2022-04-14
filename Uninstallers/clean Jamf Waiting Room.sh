#!/bin/bash

CHECKDIR="/Libary/Application\ Support/JAMF/Waiting Room"

if [ "$(ls -A $CHECKDIR)" ]
  
  then 
  find "$CHECKDIR" -type f -exec echo Found file {} \;
  find "$CHECKDIR" -type f -exec rm -r {} \;
  
  else echo "Waiting Room is Empty"

fi

