#!/usr/bin/env bash

if [[ -z `which amixer 2>/dev/null` ]]; then
    echo "-audio"
    while true; do
	sleep 1m
    done
fi

old_vol=$(amixer | grep -o '\[.*\]' | grep -o '[[:digit:]]*%' | head -n1)

echo $old_vol # initial reading

while true; do
    sleep 45s;
    vol=$(amixer | grep -o '\[.*\]' | grep -o '[[:digit:]]*%' | head -n1)
    if [[ $vol != $old_vol ]]; then # only update if necessary
	old_vol=$vol
	echo $vol
    fi
done
