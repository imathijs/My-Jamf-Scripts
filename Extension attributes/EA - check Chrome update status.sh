#!/bin/bash

result=''

if launchctl list | grep -q 'com.google.GoogleUpdater.wake.system'; then
	result='yes'
else
	result='no'
fi

echo "<result>${result}</result>"