#!/bin/bash

NAMEHOST=$(scutil --get HostName)
NAMECOMPUTER=$(scutil --get ComputerName)
NAMELOCALHOST=$(scutil --get LocalHostName)

echo -e "<result>Hostname: $NAMEHOST \nComputername: $NAMECOMPUTER \nLocalHostName: $NAMELOCALHOST</result>"

exit 0