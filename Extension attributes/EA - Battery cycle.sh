#!/bin/bash

echo "<result>$(system_profiler SPPowerDataType | awk '/Cycle Count/{print $NF}')</result>"