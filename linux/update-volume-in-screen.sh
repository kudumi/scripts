#!/bin/bash

test="ps -e | grep volume-meter.sh | cut -d ' ' -f 1"

[[ ! $test ]] && exit

for i in `ps -e | grep volume-meter.sh | cut -d ' ' -f 1`; do
    kill -USR1 $i
done
