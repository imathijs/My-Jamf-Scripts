#!/bin/bash

macosBuild=$(sw_vers -buildVersion)
macosShortVers=$(echo "$macosBuild" | head -c2)


function Download() {
	# IF MONTEREY OR HIGHER
	# MONTEREY BUILDNR = 21
	# VENTURA BUILDNR = 22
	if [ "$macosShortVers" -ge 21 ] ; then
		
		DownloadSpeed=$(/usr/bin/networkQuality -s | awk '/Downlink capacity:/ {print $3}')
		echo "<result>$DownloadSpeed</result>"
		
		if [[ -z "$DownloadSpeed" ]]; then
			
		DownloadSpeed=$(/usr/bin/networkQuality -s | awk '/Download capacity:/ {print $3}')
		echo "<result>$DownloadSpeed</result>"
			
		fi
		
	else
		echo "<result>n/a</result>"
	fi
}

Download 