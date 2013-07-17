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

# Flags
unset no_root only_root remote_host

while [[ $1 == *"-"* ]]; do
    case $1 in
	--no-root|-nr ) no_root=1 ;;
	--only-root|-or ) only_root=1 ;;

	--remote|-r )
	    remote_host=$2
	    shift

	    # To ensure the password is not asked multiple times,
	    # invoke ssh-copy-id if needed. Printing the remote host's
	    # hostname is a dummy command. The result of this block is
	    # that the user will never be prompted for the remote
	    # password more than once.
	     if [[ -z `$ssh -t $remote_host hostname 2>/dev/null` ]]; then
		 ssh-copy-id $remote_host
	     fi ;;

	* ) echo "Unrecognized flag. Ignoring $1..."
    esac
    shift
done

if [[ -z $only_root ]]; then

    # Mutt configs
    link $config/.mutt/.muttrc
    link $config/addressbook $HOME/.abook $HOME/.abook
    link $config/.mutt/passwords.gpg $HOME/.mutt $HOME/.mutt
    link $config/.mutt/centtech.muttrc $HOME/.mutt $HOME/.mutt
    link $config/.mutt/.msmtprc

    link $config/.inputrc
    link $config/.gdbinit
    link $config/.octaverc
    link $config/.gitconfig
    link $config/emacs/diary
    link $config/.Xresources
    link $config/bash/.bashrc
    link $config/.xbindkeysrc
    link $config/.xscreensaver
    link $config/emacs/.emacs.el
    link $config/emacs/.emacs.d
    link $config/screen/.screenrc
    link $config/emacs/.emacs.d/.bbdb
    link $config/emacs/.emacs.d/esc-lisp/.gnus.el
    link $config/ssh/config $HOME/.ssh $HOME/.ssh
    link $config/.rtorrent.rc  "" $HOME/.screensession  # hack
    link $config/getmailrc $HOME/.getmail $HOME/.getmail
    link $config/awesome $HOME/.config/awesome $HOME/.config
    link $config/.pianobar $HOME/.config/pianobar/config $HOME/.config/pianobar
    link $config/uzbl.config $HOME/.config/uzbl/config $HOME/.config/uzbl

    # Machine specific configuration scripts
    if [[ -e $config/machines/`hostname` ]]; then
	for file in `ls -A1 $config/machines/\`hostname\`/`; do
	    link $config/machines/`hostname`/$file
	done
    fi

fi

case `uname -a` in

    # Hardlinks are necessary because Windows does not recognize
    # symlinks like Unix does.
    *Cygwin* )			# prepare Windows
	$hardlink "$config/../scripts/windows/rc.compat.bat" \
	    "/cygdrive/c/Users/`whoami`/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/" ;;

    # TODO: if I hit C-c here, don't prompt me for sudo's password for
    # each subsequent line!
    *ARCH* )			# prepare Arch Linux
	if [[ -z $no_root ]]; then
	    link_root $config/yaourtrc
	    link_root $config/pacman.conf
	    link_root $config/bash/root.bashrc /root/.bashrc
	    link_root $config/wpa_supplicant.conf
	    link_root $config/issue
	fi
esac
