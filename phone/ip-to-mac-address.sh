#!/bin/bash

net_id="-i $HOME/.ssh/hq_rsa"
net_opts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
domain=".shoretel.com"

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
	result=`ssh -q ${net_id} ${net_opts} admin@${target} "ls /voip/*_phone | sed s/_phone// | sed s/voip// | cut -d'/' -f3 && ifconfig | grep HWaddr | head -n1 | cut -d' ' -f11 | sed s/://g" | awk 1 ORS=''`;
	echo "${target} becomes ${result}${domain}"
done
