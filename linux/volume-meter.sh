#!/bin/bash

# Singleton
# [ `ps -e | grep volume-meter.sh | wc -l` -ge 3 ] && exit 1

command="echo `amixer | grep % | head -n1 | cut -d ' ' -f 7`"
# trap "$command" USR1

$command
# while true; do
#     for i in {1..3600}; do
# 	sleep 1			# stay responsive
#     done
#     $command
# done
