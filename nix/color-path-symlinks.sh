#!/bin/bash

# Color definitions
Color_Off='\e[0m'       # Text Reset

# Variables
path="`pwd`/"
sym_color="\e[`dircolors -p | grep "symbolic link" | cut -d' ' -f 2`m"
unset output path_sans_colors

# Short representation of $HOME sweet $HOME
#path=${path/?"~"/"/home/`whoami`"}

while [[ ${path} ]]; do
    output=${output}${path%%/*}
    path_sans_colors=${path_sans_colors}${path%%/*}

    if [[ `find ${path_sans_colors} -maxdepth 0 -type l` ]]; then
	output=${output%/*}/${sym_color}${output##*/}${Color_Off}
    fi

    output=${output}/		# add the trailing /
    path_sans_colors=${path_sans_colors}/

    if [[ $path =~ .*/.* ]]; then
	path=${path#*/}
    else
	unset path
    fi
done

output=~${output#"$HOME"}       # short path
echo -e ${output%/}		# final value
