#!/bin/bash

net_id="-i $HOME/.ssh/hq_rsa"
net_opts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

function help_and_quit() {
    cat <<EOF

Usage: ${0##*/} [-i private_key] target_ips


    --id
    -d     specify the private key file used to login as
                admin on the target phones
EOF
    exit $help_exit
}


while [[ $1 == *-* ]]; do	# Parse arguments
    case $1 in

	-i|--id )
	    net_id="-i $2"
	    shift ;;

	-h|--help )
	    help_and_quit ;;

	* ) echo "$1 is not a recognized flag." ;;
    esac
    shift
done

for target in $*; do
	result=`ssh -q ${net_id} ${net_opts} admin@${target} "ifconfig | grep 'inet addr' | grep -v 127.0.0.1 | cut -d':' -f2 | cut -d' ' -f1"`;
	echo "${target} is ${result}"
done
