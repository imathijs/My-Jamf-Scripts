#!/bin/bash

MODEL="Xerox EX C60-C70 Printer (EU)"
INSTALLEDPRINTERS=$(sudo cat /etc/cups/printers.conf | awk '/^MakeModel/' | cut -f 2- -d ' ' | grep "$MODEL")

if [ "$INSTALLEDPRINTERS" == "$MODEL" ] ; then
	
	result="Printer found: $MODEL"
	
else
	
	result=""
	
fi

echo "<result>$result</result>"