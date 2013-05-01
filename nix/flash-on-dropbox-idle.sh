#!/bin/bash

# Default parameter values
time=1s

while [[ $1 == *"-"* ]]; do
    case "$1" in

	-h|--help)
	    cat <<EOF
Usage: ${0##/} [--help] [--time t]

The computer will sleep when Dropbox is in the 'Idle' state.

         -t|--time   Override the 15 second interval between battery
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

status=`dropbox status`
while [[ ${status} == *Idle* ]]; do
    echo ${status}
    status=`dropbox stauts`
    sleep ${time}
done

# Here, do the thinklight toggle
