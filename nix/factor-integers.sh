#!/usr/bin/env bash

# TODO: add help!
# This file is a port of FAST_FAC by esc on TI-83+

shopt -s extglob

for i in $(seq 2 $(echo "sqrt($1)"|bc)); do
    frac=$(echo "$1/$i"|bc -l)
    frac=${frac/%.0*/}
    if [[ -z "${frac##+([0-9])}" ]]; then
	echo "$i `echo \"$1/$i\"|bc`"
    fi
done

echo
