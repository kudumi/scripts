#!/bin/bash

LINES=$(tput lines)
COLUMNS=$(tput cols)

declare -A snowflakes
declare -A lastflakes

flake="❄"

function move_flake() {
    if [ "${snowflakes[$1]}" = "" ] || [ "${snowflakes[$1]}" = "$LINES" ]; then
        snowflakes[$1]=0
    else
        [ "${lastflakes[$1]}" != "" ] && printf "\033[%s;%sH \033[1;1H " ${lastflakes[$1]} $1
    fi

    printf "\033[%s;%sH${flake}\033[1;1H" ${snowflakes[$1]} $1

    lastflakes[$1]=${snowflakes[$1]}
    snowflakes[$1]=$((${snowflakes[$1]}+1))
}

clear				# clear screen
tput civis			# hide cursor

while true; do
    move_flake $(($RANDOM % $COLUMNS))

    for x in "${!lastflakes[@]}"; do
        move_flake "$x"
    done

    sleep 0.1
done
