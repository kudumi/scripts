#!/bin/bash

#Bug! $HOME/.ssh/config sometimes complains about bad permissions!
# Consider forcing permissions (on the duplicated files) to 600

if [[ `whoami` == root ]]; then
    echo "You had better not run this command as root!"
    exit -1
fi

install="ln -fsv"
ensure_dir_exists="mkdir -p"
config="$HOME/Dropbox/config"

function link() {
    # $3 is the parent folder that we must take special care exists,
    # if we are venturing too far from $HOME sweet $HOME.
    [[ $3 ]] && ${ensure_dir_exists} "$3"

    # $2 defaults to $HOME (if ommitted, negates the need for $3).
    install_path=$2
    if [[ -z $2 ]]; then
	install_path=$HOME
    fi

    # echo $1 should be installed in $install_path
    # return

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
    elif [[ ! -d $2 ]]; then
	# If the second directory does not exist yet, link all of $1
	$install $1 $install_path
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
unset no_root

while [[ $1 == *"-"* ]]; do
    case $1 in
	--no-root|-nr ) no_root=1 ;;
	* ) echo "Unrecognized flag. Ignoring $1..."
    esac
    shift
done

link $config/.inputrc
link $config/.octaverc
link $config/.gitconfig
link $config/.Xresources
link $config/bash/.bashrc
link $config/.rtorrent.rc
link $config/.xbindkeysrc
link $config/emacs/.emacs
link $config/emacs/.emacs.d
link $config/screen/.screenrc
link $config/emacs/.emacs.d/esc-lisp/.gnus.el
link $config/ssh/config $HOME/.ssh/config $HOME/.ssh
link $config/awesome $HOME/.config/awesome $HOME/.config
link $config/.pianobar $HOME/.config/pianobar/config $HOME/.config/pianobar
link $config/uzbl.config $HOME/.config/uzbl/config $HOME/.config/uzbl

# Machine specific configuration scripts
if [[ -e $config/machines/`hostname` ]]; then
    for file in `ls -A1 $config/machines/\`hostname\`/`; do
	link $config/machines/`hostname`/$file
    done
fi

hardlink="ln"
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
