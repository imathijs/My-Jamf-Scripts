#!/bin/bash

macosBuild=$(sw_vers -buildVersion)
macosProduct=$(sw_vers -productVersion)
macosShortVers=$(echo "$macosBuild" | head -c2)

# MALWARE REMOVAL TOOL VERSION

function system_settings() {
	if [ "$macosShortVers" -ge 21 ]; then
		# IF MACOS 12 OR HIGHER
		
		last_MRT_update_epoch_time=$(for i in $(pkgutil --pkgs=".*.XProtect.*."); do pkgutil --pkg-info $i | awk '/install-time/ {print $2}'; done | sort -n | tail -1)
		last_MRT_update_human_readable_time=$(/bin/date -r "$last_MRT_update_epoch_time" '+%Y-%m-%d %H:%M:%S')
		result="$last_MRT_update_human_readable_time"
		
	else
		# IF MACOS 11 OR LOWER
		result="macOS version not supported"
	fi

}
system_settings

echo "<result>$result</result>"