#!/bin/bash

macosBuild=$(sw_vers -buildVersion)
macosProduct=$(sw_vers -productVersion)
macosShortVers=$(echo "$macosBuild" | head -c2)

# MALWARE REMOVAL TOOL VERSION

function mrt() {
	if [ "$macosShortVers" -ge 21 ]; then
		# IF MACOS 12 OR HIGHER
		
		MRT_version=$(for i in $(pkgutil --pkgs=".*.MRT.*."); do pkgutil --pkg-info $i | awk '/version/ {print $2}'; done | sort -n | tail -1)
		result="$MRT_version"
		
	else
		# IF MACOS 11 OR LOWER
		result="macOS version not supported"
	fi

}
mrt

echo "<result>$result</result>"