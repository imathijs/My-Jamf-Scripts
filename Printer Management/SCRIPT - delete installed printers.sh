#!/bin/bash

# DELETE ALL INSTALLED PRINTER STEP BY STEP

lpstat -p | awk '{print $2}' | while read printer

do
	echo "Deleting Printer:" $printer
	lpadmin -x $printer

done

