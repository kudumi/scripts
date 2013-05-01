#!/bin/bash

pushd `dirname $0` &>/dev/null	# ensure in dir with other scripts

unset short_ckt 		# defaults
wait_for_build_completion=1

help_exit=5
latest_dne=10			# exit codes
ctrl_c_code=11
troubleshoot_mode=12

# Use this trap to ease cancelling of the script. Pressing once
# cancels the --wait flag and immediately flashes the phones
function control_c() {
    if [ -z $short_ckt ]; then
	echo "Press C-c again to quit"
	short_ckt=1
    else
	echo -e "\n"
	exit $ctrl_c_code
    fi
}
trap control_c SIGINT

function help_and_quit() {
    cat <<EOF

Usage: ${0##*/} [-w|n] [-i private_key] [-s build_server] [-b build_number|-p path_to_bin] target_ips


    --build
    -b     specify the build number used to flash the phones.
                '801.*.xxxx.*0' or \`latest'.

           The current branch may be specified with
                --build branch latest.
           CAUTION: the onus is on the user to verify the regex
                    used to identify the current branching scheme
                    is up to date. This scheme is subject to change.

    --id
    -d     specify the private key file used to login as
                admin on the target phones

    --path
    -p    specify the path to the phone binary used to flash
                the phone if other than the default

     --rpasswd
     -r    specify a root password for the pphone (used to su after
                ssh). Only specify this option if the root password is no
                longer "ShoreTel"

     --wait
     -w    wait for current build to finish building
                before taking any action. This is enabled
                by default for local builds.

     --no-wait
     -n    don't wait for current build to finish. Use
                this option if you have something else
                building.

     --server
     -s    specify a build server to download build
                images from in IPv4 format. The server
                may be referred to colloquially, such as
                'austin' or 'sunny'

EOF
    exit $help_exit
}

while [[ $1 == *"-"* ]]; do	# Parse arguments
    case $1 in

	-i|--id )
	    net_id="$1 $2"
	    shift ;;

	-w|--wait  )
	    wait_for_build_completion=1 ;;

	-n|--no-wait )
	    unset wait_for_build_completion ;;

	-r|--rpasswd )
		root_auth="$1 $2"
		shift ;;

	-p|--path )
	    phone_bin="$1 $2"
	    shift ;;

        -s|--server )

	    case $2 in
		austin ) build_server=10.17.1.17 ;;  # todo check
		sunny )  build_server=10.160.1.55 ;; # todo check
		* )      build_server=$2 ;;	     # trust the user
	    esac
	    build_server="-s $build_server"
	    shift ;;

	-b|--build )
	    unset wait_for_build_completion
	    latest_regex="^801\.[0-9]\.[0-9]*\.[0-9]*$"

	    if [[ $2 == "branch" ]]; then #change regex to branch ids
		latest_regex="^801\.[0-9]*00\.[0-9]*\.[0-9]*$"
		shift
	    fi

	    case $2 in			# Determine the build to use, if any
		801.*0 )
		    build=$2 ;;
		latest )
		    build=`ls -1r /mnt/builds/ | grep -e${latest_regex} 2>/dev/null | head -n1`
		    [[ -z $build ]] && cat <<EOF && exit $latest_dne ;;

Could not determine latest build number. Do you have the build directory mounted
at /mnt/builds/? Are you in a dev environment?
EOF
	    esac
	    build="-b ${build##*/}"
	    shift ;;

	-h|--help )
	    help_and_quit ;;

	* ) echo "$1 is not a recognized flag." ;;
    esac
    shift
done

if [ $wait_for_build_completion ]; then
    echo -n "Ensuring build completion..."
    while [[ -n `ps -e | grep make` && -z $short_ckt ]]; do # short on Ctrl-c
	sleep 1 &>/dev/null;	# busy-wait
    done
    echo "done"
fi

unset feedback			# capture error codes here
color_arr=('\e[40m' '\e[41m' '\e[42m' '\e[43m' '\e[44m' '\e[45m' '\e[46m' '\e[47m' '\e[0;90m' '\e[0;91m' '\e[0;92m' '\e[0;93m' '\e[0;94m' '\e[0;95m' '\e[0;96m' '\e[0;97m' '\e[1;29m' '\e[1;31m' '\e[1;32m' '\e[1;33m' '\e[1;34m' '\e[1;35m' '\e[1;36m' '\e[1;37m' '\e[4;30m' '\e[4;31m' '\e[4;32m' '\e[4;33m' '\e[4;34m' '\e[4;35m' '\e[4;36m' '\e[4;37m')
feedback=$(for phone in $*; do
	# Pick a color for differentiating output between phones

	color="--oid ${color_arr[$RANDOM % ${#color_arr[*]}]}"

    (./flash-phone.sh $net_id $root_auth $color $phone_bin $build $build_server $phone >&2 & \
	wait %1; code=$?; [ $code -ne 0 ] && echo $phone:$code ) &

done)

[[ -z $feedback ]] && exit $success # no errors, graceful exit

# Begin troubleshooting mode
cat <<EOF

Here is what I know: these hosts were not updated successfully, and
this is the error code associated with each failure
EOF
echo -e "$feedback\n"
exit $troubleshoot_mode
