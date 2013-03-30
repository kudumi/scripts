#!/bin/bash

help_and_quit=-2

Color_Off='\e[0m'       # Text Reset
BBlack='\e[1;29m'       # Bold black

main=/depot/phone/proj/main
performance=/depot/phone/dev

# Everybody should be working on the performance branch
pushd ${performance}/bca_refactor/scripts &>/dev/null # ensure in dir with other scripts
branch_name="performance"

while [[ "$1" == *"-"* ]]; do	# Parse arguments
    case "$1" in
	-h|--help)
	    cat <<EOF
Usage: ${0##*/} [-h] [main]

       *** UNTESTED without ecrosson's shelved CL 366215 ***

       This script will 'get latest revision' for main and performance
       branches, and will proceed to build the new phone binaries for
       the specified branch. This can help reduce subsequent build
       times for the remainder of the work day.

       If [main] is specified, this script will build binaries from
       the main branch instead of the performance branch.

      -h|--help    Will show this help dialog
EOF
	    exit ${help_and_quit} ;;

	main)
	    pushd ${main}/scripts &>/dev/null # ensure in dir with other scripts
	    branch_name="main" ;;
    esac

    shift			# next arg
done

# Update main and performance branches
echo -e "${BBlack}Updating local repository...${Color_Off}"
p4 sync ${main}/...#head
p4 sync ${performance}/...#head

time (
    for i in p2 p8 p8cg; do
	echo -e "${BBlack}Building the ${branch_name} branch for $i${Color_Off}"
	./build-shoretel.sh $i embedded release || break
    done
)
