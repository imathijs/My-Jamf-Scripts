#!/bin/sh
#Determine model
model=`system_profiler SPHardwareDataType | grep "Model Name:" | cut -d ' ' -f 9`

if [[ "$model" =~ "Book" ]]; then

#Determine battery condition
result=`system_profiler SPPowerDataType | grep "Condition" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//'`
echo "<result>$result</result>"
else
echo "<result>Not A MacBook</result>"
fi