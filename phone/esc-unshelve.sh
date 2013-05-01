err_code=-2

# Colors
Color_Off='\e[0m'       # Text Reset
BCyan='\e[1;36m'        # Cyan

function revert_and_checkout() {
    p4 revert $1
    p4 unshelve -s ${shelf} -c default $1
}

function help_and_quit() {
cat <<EOF

Usage: ${0##*/} [-a] change-list

    --all
    -a     unshelve all files in the shelf, including header files
EOF
    exit $err_code
}

unset header

while [[ $1 == *-* ]]; do
    case $1 in
	-h|--help)
	    help_and_quit ;;
	-a|--all)
	    header=1 ;;
    esac
    shift
done

shelf=$1
shift

echo -e ${BCyan}Reverting all files in the default changelist...${Color_Off}
p4 revert -c default //...

echo -e ${BCyan}Unshelving CL ${shelf}...${Color_Off}
output=$(p4 describe ${shelf})
output=${output##Affected files ...}

for file in $output; do
	if [[ $file =~ //.*#* ]]; then
		if [[ $file =~ *.h#* && $header == 0 ]]; then
			continue;
		fi
		revert_and_checkout ${file%%#*}
	fi
done
