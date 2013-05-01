#!/bin/bash

success=0			# error codes
help_exit=5
net_id_dne=6
error_scping=7
phone_bin_dne=8
error_stripping=9

function help_and_quit() {
cat <<EOF

Usage: ${0##*/} [-p|--path] [-b build_number] [-s build_server] target_ip
    where [build_server] is an IPv4 address.

    --build
    -b     specify the build number used to flash the phones.
                '801.x.xxxx.*0' or \`latest'

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

     --rpasswd
     -r    specify a root password for the pphone (used to su after
                ssh). Only specify this option if the root password is no
                longer "ShoreTel"

EOF
    exit $help_exit
}

unset phone_bin phone_model		# defaults
Color_Off='\e[0m'
net_id="$HOME/.ssh/hq_rsa"
rpasswd="ShoreTel"
bld_server=10.160.1.55

while [[ $1 == *"-"* ]]; do	# Parse arguments
    case $1 in

    -p|--path )    phone_bin=$2 ;;
	-i|--ident )   net_id=$2 ;;
	-b|--build )   build=$2 ;;
	-s|--server )  bld_server=$2 ;;
	-r|--rpasswd ) rpasswd=$2 ;;
	-h|--help )    help_and_quit ;;
	-o|--oid )     oid=$2 ;;

	* ) echo "$1 is not a recognized flag." ;;
    esac

    shift
	shift
done

if [[ ! -e $net_id ]]; then		# check the remote identity file
    echo "$net_id does not exist."
    exit $net_id_dne
fi

target=$1

if [[ $build ]]; then			# we are using build numbers
    update_cmd="update-stage $build $bld_server; update-do $build"

    ./run-cmd-as-root.sh "$net_id" $target "$update_cmd" "$rpasswd" #&>/dev/null
    exit $success

elif [ $# -eq 0 ]; then		# invoked incorrectly if no args
    help_and_quit
fi

net_opts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
stripper="/depot/phone/make/home/PhonexChange/WRL/wrl3.GA/wrlinux-3.0/layers/wrll-toolchain-4.3-85/arm/toolchain/x86-linux2/bin/arm-wrs-linux-gnueabi-strip"

remote_folder="/tmp/"
del_and_move="del-and-move.sh"
chmod +x $del_and_move &>/dev/null

if [ -z $phone_bin ]; then	# we have to figure out which binary to use
	if [ -z $phone_model ]; then # ask the phone for its model
		output=`ssh -q -i $net_id $net_opts  admin@${target} ls /voip/*_phone`
		output=${output%%_*}		# chop off the _phone
		phone_type=${output##*/}	# drop the absolute path
	fi

    phone_bin="../shoretel/pphone/bin/${phone_type}/embedded/${phone_type}_phone"
fi

if [[ `du -h ${phone_bin} | cut -f1 | cut -d'M' -f1` -gt 20 ]]; then
	echo -e "${oid}Stripping the phone binary of unnecessary symbols...${Color_Off}"
	$stripper $phone_bin &>/dev/null || exit $err_stripping
	[ ! -s $phone_bin ] && exit $phone_bin_dne
else
	echo -e "${oid}Not stripping the phone binary- already naked.${Color_Off}"
fi

echo -e "${oid}Ensuring clean workspace...${Color_Off}"
./run-cmd-as-root.sh "${net_id}" $target "rm /tmp/${del_and_move}" "$rpasswd" &>/dev/null

echo -e "${oid}Transferring new phone image...${Color_Off}"
scp -qC -i $net_id $net_opts $phone_bin $del_and_move admin@${1}:${remote_folder} 2>/dev/null \
    || exit $err_scping

./run-cmd-as-root.sh "${net_id}" $target "${remote_folder}${del_and_move}" "$rpasswd" #&>/dev/null
