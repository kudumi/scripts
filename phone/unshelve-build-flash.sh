#!/bin/bash

help_exit=5

# Colors
Color_Off='\e[0m'       # Text Reset
BCyan='\e[1;36m'        # Cyan

function help_and_quit() {
    cat <<EOF

Usage: ${0##*/} [-a] -cl CHANGE-LIST {phone models to update}

This script will unshelve a changelist with `esc-unshelve.sh',
                 compile the new code base with `build-shoretel.sh',
             and update all phones matching the specified hardware versions.

     -a     unshelve ALL files (indicating .h or header files)

     -cl    the changelist to unshelve

Finally, include a list of phone models to update, i.e. p2 p8
EOF
    exit $help_exit
}

while [[ $1 == *"-"* ]]; do	# Parse arguments
    case $1 in
		-a|--all )
			unshelve_args=$1 ;;

		-i|--id )
			net_id="$1 $2"
			shift ;;

		-cl )
			unshelve_cl=$2
			shift ;;

		-h|--help )
			help_and_quit ;;

		* ) echo "$1 is not a recognized flag." ;;
    esac
    shift
done

pphones="$*"

esc-unshelve.sh ${unshelve_args} ${unshelve_cl}
for i in ${pphones}; do
	echo -e ${BCyan}Building phone version for ${i}${Color_Off}
	./build-shoretel.sh $i embedded release || break;
	model=${i}s
	echo -e ${BCyan}Flashing phones of type ${i}${Color_Off}
	./update-phones.sh ${!model}
done
