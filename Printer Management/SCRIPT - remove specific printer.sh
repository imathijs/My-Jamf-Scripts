#!/bin/bash

# PRINTER MODEL, CHANGE IT...
MODEL="Brother HL-L2350DW series-AirPrint"

# PRINTERS.CONF
PRINTCONF=/etc/cups/printers.conf

#COUNT INSTALLED PRINTERS
CPRINT=$(cat $PRINTCONF | grep -c "$MODEL")

echo -e "$MODEL \n$CPRINT printer(s) installed: \n-----------------------"

while read line; do
	# READING EACH LINE
	START=$(echo $line | grep '<Printer' -c)
	
	if [ "$START" == "1" ]; then
		PNAME=$(echo $line | sed 's/<Printer //' | sed 's/>//')
	fi
	
	MODELP=$(echo $line | grep 'MakeModel' -c)
	
	if [ "$MODELP" == "1" ]; then
		PMODEL=$(echo $line | cut -d" " -f2- | sed 's/>//g')
		LIST=$(echo $PNAME - $PMODEL)
		PRINTER=$(echo $LIST | grep "$MODEL" | awk '{print $1}')
		
		if [ -n "$PRINTER" ]; then
			echo "Name printer: $PRINTER"
			#DELETE PRINTER
			lpadmin -x $PRINTER
		fi
	fi
	
	n=$((n+1))
	
done < $PRINTCONF
