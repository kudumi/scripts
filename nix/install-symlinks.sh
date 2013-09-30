#!/usr/bin/env bash

#TODO: $HOME/.ssh/config sometimes complains about bad permissions!
# Consider forcing permissions (on the duplicated files) to 600

if [[ `whoami` == root ]]; then
    echo "You had better not run this command as root!"
    exit -1
fi

# Only prompt for sudo passwd once
function control_c() { exit 1 ;}
trap control_c SIGINT

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

    # $3 is the parent folder that we must take special care exists
    [[ $3 ]] && ${ensure_dir_exists} "$3" 2>/dev/null

    install_path=${2:-$HOME} # If $2 ommitted, no need for $3.

    # If the second directory does not exist yet, create it
    [[ ! -e $install_path && ! -d $install_path ]] && ${ensure_dir_exists} $install_path

    if [[ -d $1 && -d $install_path ]]; then
	# When installing a directory that already exists, we need to
	# tread lightly. Removing the directory is no good- if the
	# user has some custom files in that directory that we're not
	# expecting to exist, then removing the entire directory would
	# not be nice. As such, we have to copy the contents of $1
	# into ${install_path}, rather than linking all of ${install_path}.
	for file in $1/*; do
	    rm -rf $install_path/${file##*/} # no mercy for subdirs I am overwriting
	    $install $file $install_path/${file##*/}
	done
    else
	# Otherwise, we are dealing with a single file. Let's link it directly
	$install ${1%/} ${install_path%/}
    fi

    chown `whoami` $install_path # take ownership of the new file
}

# This function is a stripped down version of link (above). It only
# handles files, not entire directories.
# $2 defaults to /etc
function link_root() {
    install_path=${2:-/etc}  # defaults to /etc, home for root configs
    sudo $install ${1%/} ${install_path%/}
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


	* ) error "Unrecognized flag: $1"
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
    link $config/.mutt/.muttrc.utexas            $HOME/.mutt
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
    link $config/emacs/.emacs.d $HOME/.emacs.d
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

    # TODO: Watch out here! This section may require root access to fully install
    section "Installing web configs"
    link $config/elinks.conf $HOME/.elinks $HOME/.elinks

    # Copy all files except root config and userscripts. The root
    # config is linked later (in the root section), while the
    # userscripts are never linked.
    subnote "Installing uzbl configs"
    for file in `ls -A1p $config/uzbl/ | grep -v '/' | grep -v 'uzbl-dir.sh'`; do
	link $config/uzbl/$file $HOME/.config/uzbl
    done

    section "Installing miscellaneous configs"
    link $config/.inputrc
    link $config/.octaverc
    link $config/.rtorrent.rc  "" $HOME/.screensession  # hack
    # link $config/getmailrc $HOME/.getmail $HOME/.getmail
    link $config/.pianobar $HOME/.config/pianobar/ $HOME/.config/pianobar
    mv $HOME/.config/pianobar/.pianobar $HOME/.config/pianobar/config

    # Machine specific configuration scripts
    section "Installing host-specific configs"
    if [[ -e $config/machines/`hostname` ]]; then
	for file in `ls -A1 $config/machines/\`hostname\`/`; do
	    link $config/machines/`hostname`/$file
	done
	case `hostname` in
	    #TODO: extract this somewhere else. This should be a generic script!
	    nemo)
		if [[ -z $no_root ]]; then

		    subnote "Installing root configs for `hostname`"
		    link_root $config/machines/`hostname`-root/modprobe.conf     /etc/modprobe.d/modprobe.conf
		    link_root $config/machines/`hostname`-root/no-pcspkr.conf    /etc/modprobe.d/no-pcspkr.conf
		    link_root $config/machines/`hostname`-root/no-ethernet.conf  /etc/modprobe.d/no-ethernet.conf
		    link_root $config/machines/`hostname`-root/no-bluetooth.conf  /etc/modprobe.d/no-bluetooth.conf
		    link_root $config/machines/`hostname`-root/20-thinkpad.conf  /etc/X11/xorg.conf.d/20-thinkpad.conf # TrackPoint config
		    link_root $config/machines/`hostname`-root/50-synaptics.conf /etc/X11/xorg.conf.d/50-synaptics.conf # Touchpad config
		    link_root $config/machines/`hostname`-root/system-sleep.sh   /usr/lib/systemd/system-sleep/sleep.sh # To avoid iwlwifi errors
		    link_root $config/machines/`hostname`-root/rc.local.shutdown # To avoid errors with power saving tools' failure to distinquish sys devices
		    link_root $config/machines/`hostname`-root/rc.local.shutdown.service /usr/lib/systemd/system-rc-local-shutdown.service

		    subnote "Installing makepkg config"
		    link_root $config/machines/`hostname`-root/makepkg.conf
		fi
		;;
	esac
    fi
fi

section "Installing operating system-specific configs"
case `uname -a` in

    # Hardlinks are necessary because Windows does not recognize
    # symlinks like Unix does. Probably a Cygwin deficiency.
    *Cygwin* )			# prepare Windows
	#TODO: make this section generic
	# for file in $config/windows/*.*; do
	#     echo ${file##*/}
	# done
	link $config/windows/.screenrc

	$hardlink 2>/dev/null "$config/../scripts/windows/rc.compat.bat" \
	    "/cygdrive/c/Users/`whoami`/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/" ;;

    *ARCH*|*LIBRE* )		# prepare Arch Linux, Parabola
	if [[ -z $no_root ]]; then

	    section "Installing root configs"
	    link_root $config/issue
	    link_root $config/yaourtrc
	    link_root $config/pacman.conf
	    link_root $config/chrony.conf
	    link_root $config/jre.sh /etc/profile.d
	    link_root $config/bash/.bashrc.root.sh /root/.bashrc

	    section "Installing systemd 'drop-in' configuration files"
	    systemd_drop=/etc/systemd/system/getty@.service.d
	    sudo mkdir -p ${systemd_drop}
	    link_root $config/systemd/activate-numlock.conf ${systemd_drop}/activate-numlock.conf

	    section "Installing configs for Xtreme Power Savings"
	    link_root $config/systemd/sysctl.conf
	    link_root $config/systemd/disable-watchdog.conf /etc/sysctl.d/disable-watchdog.conf
	    link_root $config/systemd/activate-numlock.conf /etc/sysctl.d/
	    link_root $config/udev/pci-pm.rules         /etc/udev/rules.d/pci-pm.rules
	    link_root $config/udev/backlight.rules      /etc/udev/rules.d/backlight.rules
	    link_root $config/udev/usb-powersave.rules  /etc/udev/rules.d/usb-powersave.rules
	    link_root $config/udev/70-disable-wol.rules /etc/udev/rules.d/70-disable-wol.rules
	    link_root $config/udev/70-wifi-powersave.rules /etc/udev/rules.d/70-wifi-powersave.rules

	    #TODO: This breaks uzbl
	    section "Installing root uzbl configs"
	    link_root $config/uzbl/uzbl-dir.sh /usr/share/uzbl/examples/data/scripts/util

	    if [[ $not_shared ]]; then
		# If the wireless config is necessary
		[[ `ip addr | grep wlp` ]] && link_root $config/wpa_supplicant.conf
		link_root $config/hosts # block facebook
            fi
	fi
esac
