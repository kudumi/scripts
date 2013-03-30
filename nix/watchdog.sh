#!/bin/bash

# Default parameter values
time=1m

while [[ $1 == *"-"* ]]; do
    case "$1" in

	-h|--help)
	    cat <<EOF
Usage: ${0##/} [--help] [--time t] target-battery-percentage

Supply a target battery percentage, and the computer will sleep when
the battery reaches that level.

         -t|--time   Override the 1 minute interval between battery
                     status checks. Specify a number and time
                     interval, ie '30s' or '15m' or '1h'
EOF
	    ;;

	-t|--time)
	    time=$2
	    shift ;;
    esac

    shift
done

target=$1
percent=`acpi | cut -d' ' -f4 | cut -d'%' -f1`

echo "Hibernating when battery reaches ${target}%"

while [[ ${percent} -gt ${target} ]]; do
    percent=`acpi | cut -d' ' -f4 | cut -d'%' -f1`
    echo -ne "\r`acpi`"
    sleep ${time}
done

systemctl suspend
