#!/bin/bash

# Default parameter values
time=1s

while [[ $1 == *"-"* ]]; do
    case "$1" in

	-h|--help)
	    cat <<EOF
Usage: ${0##/} [--help] [--time t]

The program will halt until all `*.crdownload' files are removed from
the ~/Downloads directory.

         -t|--time   Override the 1 second interval between battery
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

echo "Waiting for downloads to complete..."
output=`ls -1 $HOME/Downloads/*.crdownload`
while [[ $output ]]; do
    output=`ls -1 $HOME/Downloads/*.crdownload`
    sleep ${time}
done

echo "All downloads are complete: continuing"
