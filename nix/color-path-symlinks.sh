#!/bin/bash

# Color definitions
Color_Off='\e[0m'       # Text Reset

# Variables
path="`pwd`/"
sym_color="\e[`dircolors -p | grep "symbolic link" | cut -d' ' -f 2`m"
unset output

# Short representation of $HOME sweet $HOME
#path=${path/?"~"/"/home/`whoami`"}

while [[ ${path} ]]; do
    output=${output}${path%%/*}

    if [[ `find ${output#'~'} -maxdepth 0 -type l` ]]; then
	output=${output%/*}/${sym_color}${output##*/}${Color_Off}
    fi

    output=${output}/		# add the trailing /

    if [[ $path =~ .*/.* ]]; then
	path=${path#*/}
    else
	unset path
    fi
done

echo ${output%/}		# final value
