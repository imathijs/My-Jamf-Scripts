#!/bin/bash

# REMOVE SPECIFIC PRINTER
# EXAMPLE MODEL="Xerox EX C60-C70 Printer (EU)"

MODEL="Xerox EX C60-C70 Printer (EU)"
OLDPRINTER=$(cat /etc/cups/printers.conf | grep "$MODEL" -B 5 | head -n 1 | sed 's/<Printer //' | sed 's/>//')

lpadmin -x "$OLDPRINTER"

exit 0

