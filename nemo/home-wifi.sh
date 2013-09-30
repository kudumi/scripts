#!/bin/bash

source $HOME/Dropbox/config/bash/bash.error.sh

while [[ $1 == -* ]]; do
    case $1 in

	-h|--help)
	    cat<<EOF
`basename $0` [ip to assign] [ip of router] [ip of nameserver]

A script to connect to home wifi during this dark, dark
time of intermittent connection.

              For more information, try \`cmdcat `basename $0`\`.

Possible arguments are as follows

         --help
         -h       Display this help information. `basename $0` has no man page.
EOF
	    exit $EXIT_HELP
	    ;;
    esac
    shift
done

sudo dhcpcd -S ip_address=${1:-192.168.0.111} -S routers=${2:-192.168.0.1} -S domain_name_servers=${3:-8.8.8.8}
