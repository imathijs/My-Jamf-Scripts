#!/bin/bash

# Files to check and remove
file1="/Library/Security/Reports/CISBenchmarkReport.csv"
file2="/Library/Managed Preferences/com.cis.benchmark.plist"

# Check if file1 exists and remove it
if [ -f "$file1" ]; then
	echo "File $file1 found. Removing..."
	rm "$file1"
	if [ $? -eq 0 ]; then
		echo "$file1 successfully removed."
	else
		echo "Error removing $file1."
	fi
else
	echo "$file1 not found."
fi

# Check if file2 exists and remove it
if [ -f "$file2" ]; then
	echo "File $file2 found. Removing..."
	rm "$file2"
	if [ $? -eq 0 ]; then
		echo "$file2 successfully removed."
	else
		echo "Error removing $file2."
	fi
else
	echo "$file2 not found."
fi