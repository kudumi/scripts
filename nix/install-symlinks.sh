#!/bin/bash

#TODO: $HOME/.ssh/config sometimes complains about bad permissions!
# Consider forcing permissions (on the duplicated files) to 600

if [[ `whoami` == root ]]; then
    echo "You had better not run this command as root!"
    exit -1
fi

# Commands with arguments
hardlink="ln"
install="ln -fsv"
ensure_dir_exists="mkdir -p"
copy="rsync -Prahz --rsh=ssh"
ssh="ssh -o PreferredAuthentications=publickey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Paths
config="$HOME/Dropbox/config"

function link() {
    # If we are installing to a remote host, we don't need to use any
    # form of links. Simply copy the file over to the host in the
    # appropriate directory (overwriting existing files, not dirs).
    if [[ $remote_host ]]; then
	# We have to take care of the explicit dependencies for the
	# install_path

	# TODO! redirection so $HOME here becomes real $HOME in $remote_host
	[[ $3 ]] && $ssh -t $remote_host mkdir -p $3
	$copy $1 $remote_host:$2
	##### end We have to
	return
    fi

    # $3 is the parent folder that we must take special care exists,
    # if we are venturing too far from $HOME sweet $HOME.
    [[ $3 ]] && ${ensure_dir_exists} "$3"

    # $2 defaults to $HOME (if ommitted, negates the need for $3).
    install_path=$2
    [[ -z $2 ]] && install_path=$HOME

    # If the second directory does not exist yet, create it
    [[ ! -e $install_path && ! -d $install_path ]] && mkdir $install_path

    if [[ -d $1 && -d $2 ]]; then
	# When installing a directory that already exists, we need to
	# tread lightly. Removing the directory is no good- if the
	# user has some custom files in that directory that we're not
	# expecting to exist, then removing the entire directory would
	# not be a nice move. As such, we have to copy the contents of
	# $1 into $2, rather than linking all of $2.
	for file in $1/*; do
	    rm -rf $install_path/${file##*/} # no mercy for folders I am overwriting
	    $install $file $install_path/${file##*/}
	done
    else
	# Otherwise, we are dealing with a single file. Let's link it directly
	$install $1 $install_path
    fi

    chown `whoami` $install_path # take ownership of the new file
}

# This function is a stripped down version of link (above). It only
# handles files, not entire directories.
# $2 defaults to /etc
function link_root() {
    install_path=$2
    [[ -z $2 ]] && install_path=/etc
    sudo $install $1 $install_path
}

# Includes
source $HOME/Dropbox/config/bash/bash.io.sh
loadFile ${bash_config}/bash.colors.sh

# Flags
unset no_root only_root remote_host not_shared

while [[ $1 ]]; do
    case $1 in
	--no-root|-nr ) no_root=1 ;;
	--only-root|-or ) only_root=1 ;;
	--not-shared|-ns ) not_shared=1 ;;

	--remote|-r )
	    remote_host=$2
	    shift

	    # To ensure the password is not asked multiple times,
	    # invoke ssh-copy-id if needed. Printing the remote host's
	    # hostname is a dummy command. The result of this block is
	    # that the user will never be prompted for the remote
	    # password more than once.
	    [[ -z `$ssh -t $remote_host hostname 2>/dev/null` ]] && \
		ssh-copy-id $remote_host ;;

	--help|-h)

            cat<<EOF

 Only use this program if you are quite certain of what you are doing.

    Control over installed files:
       --no-root    -nr     Don't install files in /etc
       --only-root  -or     Only install files in /etc
       --not-shared -ns     This is not a shared machine, overwrite ONLY esc's stuff in /etc

    Other functions:
       --remote     -r      Install to a remote host (not functional)
       --help       -h      Display this menu

EOF
            exit 1 ;;


	* ) echo "Unrecognized flag: $1"
	    exit 1 ;;
    esac
    shift
done

if [[ -z $only_root ]]; then

    section "Installing mail configs"
    link $config/.mutt/muttrc                   $HOME/.mutt  $HOME/.mutt/cache
    link $config/.mutt/.mutt.colors              $HOME/.mutt
    link $config/.mutt/.mutt.macros              $HOME/.mutt
    link $config/.mutt/.mutt.bindings            $HOME/.mutt
    link $config/.mutt/.mutt.passwords.gpg       $HOME/.mutt
    link $config/.mutt/.muttrc.centtech          $HOME/.mutt
    link $config/.mutt/.muttrc.esc               $HOME/.mutt
    link $config/addressbook                     $HOME/.abook $HOME/.abook

    subnote "Installing mailcap file"
    link $config/.mutt/.mailcap $HOME/.mutt

    subnote "Installing msmtp configs"
    link $config/.mutt/.msmtprc.gpg
    link $config/.netrc.gpg

    subnote "Installing imapfilter configs"
    link $config/.imapfilter/esc.gpg                   $HOME/.imapfilter $HOME/.imapfilter
    link $config/.imapfilter/config.lua                $HOME/.imapfilter
    link $config/.imapfilter/centtech.gpg              $HOME/.imapfilter
    link $config/.imapfilter/imapfilter-functions.lua  $HOME/.imapfilter

    section "Installing gpg configs"
    link $config/gpg.conf       $HOME/.gnupg $HOME/.gnupg
    link $config/gpg-agent.conf $HOME/.gnupg

    section "Installing Emacs configs"
    link $config/.gdbinit
    link $config/emacs/diary
    link $config/emacs/.emacs.d
    link $config/emacs/.emacs.el
    link $config/emacs/.emacs.d/.bbdb
    # link $config/emacs/.emacs.d/esc-lisp/.gnus.el

    section "Installing awesome configs"
    link $config/awesome $HOME/.config/awesome $HOME/.config

    section "Installing git configs"
    link $config/.gitconfig

    section "Installing xorg configs"
    link $config/.Xresources
    link $config/.xbindkeysrc
    link $config/.xscreensaver

    section "Installing shell configs"
    link $config/bash/.bashrc

    section "Installing ssh configs"
    link $config/ssh/config $HOME/.ssh $HOME/.ssh

    section "Installing screen configs"
    link $config/screen/.screenrc

    #TODO: Watch out here! This section may require root access to fully install
    section "Installing web configs"
    link $config/elinks.conf $HOME/.elinks $HOME/.elinks

    subnote "Installing uzbl configs"
    # Copy all files except one (called out in backticks.) This file
    # goes to another dir (see root section below)
    for file in `ls -A1 $config/uzbl/ | grep -v 'uzbl-dir.sh'`; do
	link $config/uzbl/$file $HOME/.config/uzbl
    done

    section "Installing miscellaneous configs"
    link $config/.inputrc
    link $config/.octaverc
    link $config/.rtorrent.rc  "" $HOME/.screensession  # hack
    # link $config/getmailrc $HOME/.getmail $HOME/.getmail
    link $config/.pianobar $HOME/.config/pianobar/config $HOME/.config/pianobar

    # Machine specific configuration scripts
    section "Installing host-specific configs"
    if [[ -e $config/machines/`hostname` ]]; then
	for file in `ls -A1 $config/machines/\`hostname\`/`; do
	    link $config/machines/`hostname`/$file
	done
    fi
fi

section "Installing operating system-specific configs"
case `uname -a` in

    # Hardlinks are necessary because Windows does not recognize
    # symlinks like Unix does. Probably a Cygwin deficiency.
    *Cygwin* )			# prepare Windows
	$hardlink "$config/../scripts/windows/rc.compat.bat" \
	    "/cygdrive/c/Users/`whoami`/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/" ;;

    *ARCH*|*LIBRE* )		# prepare Arch Linux, Parabola
	if [[ -z $no_root ]]; then

	    # Only prompt for sudo passwd once
	    function control_c() { exit 1 ;}
	    trap control_c SIGINT

	    section "Installing root configs"
	    link_root $config/issue
	    link_root $config/yaourtrc
	    link_root $config/pacman.conf
	    link_root $config/bash/.bashrc.root.sh /root/.bashrc

	    section "Installing root uzbl configs"
	    link_root $config/uzbl/uzbl-dir.sh /usr/share/uzbl/examples/data/scripts/util

	    if [[ $not_shared ]]; then
		# If the wireless config is necessary
		[[ `ip addr | grep wlp` ]] && link_root $config/wpa_supplicant.conf
		link_root $config/hosts # block facebook
            fi
	fi
esac
