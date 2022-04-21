#!/bin/bash

# PRINTER MODEL, CHANGE IT...
MODEL="Brother HL-L2350DW series-AirPrint"

# PRINTERS.CONF
PRINTCONF=/etc/cups/printers.conf

#COUNT INSTALLED PRINTERS
CPRINT=$(cat $PRINTCONF | grep -c "$MODEL")

echo -e "<result>$MODEL \n$CPRINT printer(s) installed</result>"
