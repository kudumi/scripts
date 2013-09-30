#!/usr/bin/env bash

# Color definitions
Color_Off='\e[0m'       # Text Reset

# Variables
path="`pwd`/"
sym_color="\e[`dircolors -p | grep "symbolic link" | cut -d' ' -f 2`m"
unset output path_sans_colors

while [[ ${path} ]]; do
    output=${output}${path%%/*}
    path_sans_colors=${path_sans_colors}${path%%/*}

    [[ `find ${path_sans_colors} -maxdepth 0 -type l 2>/dev/null` ]] && \
	output=${output%/*}/${sym_color}${output##*/}${Color_Off}

    output=${output}/		# add the trailing /
    path_sans_colors=${path_sans_colors}/

    if [[ $path =~ .*/.* ]]; then
	path=${path#*/}		# examine the next dir
    else
	unset path		# no more dirs
    fi
done

output=${output/"/home/`whoami`"/"~"} # short paths
echo -e ${output%/}		      # final value
