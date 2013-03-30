#!/bin/bash

net_id="$HOME/.ssh/hq_rsa"
err_code=5

function help_and_quit() {
cat <<EOF

Usage: ${0##*/} [-p|--path] [-b build_number] [-s build_server] target_ip
    where [build_server] is an IPv4 address.

    --build
    -b     specify the build number used to flash the phones.
                '801.x.xxxx.0' or \`latest'

    --id
    -d     specify the private key file used to login as
                admin on the target phones

    --path
    -p    specify the path to the phone binary used to flash
                the phone if other than the default

     --server
     -s    specify a build server to download build
                images from in IPv4 format. The server
                may be referred to colloquially, such as
                'austin' or 'sunny'

EOF
    exit $err_code
}

unset phone_bin
bld_server=10.160.1.55

while [[ $1 == *-* ]]; do	# Parse arguments
    case $1 in

        -p|--path )
	    phone_bin=$2
	    shift ;;

	-i|--ident )
	    net_id=$2
	    shift ;;

	-b|--build )
	    build=$2
	    shift ;;

	-s|--server )
	    bld_server=$2
	    shift ;;

	-h|--help )
	    help_and_quit ;;

	* ) echo "$1 is not a recognized flag." ;;
    esac
    shift
done

if [ ! -e $net_id ]; then	# check the remote identity file
    echo "$net_id does not exist."
    exit $err_code
fi

target=$1

if [ $build ]; then		# we are using build numbers
    update_cmd="update-stage $build $bld_server; update-do $build"

    ./run-cmd-as-root.sh $net_id $target "$update_cmd" #&>/dev/null
    exit 0

elif [ $# -eq 0 ]; then		# invoked incorrectly if no args
    help_and_quit
fi

net_opts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
stripper="/depot/phone/make/home/PhonexChange/WRL/wrl3.GA/wrlinux-3.0/layers/wrll-toolchain-4.3-85/arm/toolchain/x86-linux2/bin/arm-wrs-linux-gnueabi-strip"

remote_folder="/tmp/"
del_and_move="del-and-move.sh"
chmod +x $del_and_move &>/dev/null

if [ -z $phone_bin ]; then	# ask the phone for its model
    output=`ssh -q -i $net_id $net_opts admin@${target} ls /voip/*_phone`
    output=${output%%_*}	# chop off the _phone
    phone_type=${output##*/}	# drop the absolute path

    phone_bin="/depot/phone/proj/main/shoretel/pphone/bin/${phone_type}"
    phone_bin="${phone_bin}/embedded/${phone_type}_phone"
fi

#echo -n "Strip the phone binary of unnecessary symbols..."
$stripper $phone_bin &>/dev/null || exit $err_code

#echo "Transferring new phone image..."
scp -i $net_id $net_opts $phone_bin $del_and_move admin@${1}:${remote_folder} \
    || exit $err_code

./run-cmd-as-root.sh "${net_id}" $target "${remote_folder}${del_and_move}" #&>/dev/null
