#!/bin/bash

#Found a bug! Bad owner or permissions on /cygdrive/c/Users/ecrosson/.ssh/config
# Solution: chown each file

#Bug! symlinks of directories are placed inside of directories instead
#of overwriting;
# Solution: reverse mkdir -p, that is, delete each directory first
# hold on:..... that sounds scary. Lets deliberate

# Install all symlinks in the config folder to their respective homes.

#Bug! $HOME/.ssh/config sometimes complains about bad permissions!
# Consider forcing permissions (on the duplicated files) to 600

link="ln -fsv"
hardlink="ln"
mkdir="mkdir -p"
remove="rm -rf"
config="$HOME/Dropbox/config"

# Dependencies
mkdir $HOME/.ssh
mkdir $HOME/.config
mkdir $HOME/.config/pianobar

# Directories to clear (caveat emptor)
$remove $HOME/.emacs.d
$remove $HOME/.config/awesome

$link $config/emacs/.emacs $HOME/.emacs
$link $config/emacs/.emacs.d $HOME/.emacs.d
$link $config/bash/bashrc $HOME/.bashrc
$link $config/awesome $HOME/.config/awesome
$link $config/gitconfig $HOME/.gitconfig
$link $config/pianobar $HOME/.config/pianobar/config
$link $config/rtorrentrc $HOME/.rtorrent.rc
$link $config/screen/screenrc $HOME/.screenrc
$link $config/ssh/config $HOME/.ssh/config
$link $config/xbindkeysrc $HOME/.xbindkeysrc
$link $config/xresources $HOME/.Xresources
$link $config/yaourtrc $HOME/.yaourtrc
$link $config/octaverc $HOME/.octaverc
$link $config/.gnus.el $HOME/.gnus.el
$link $config/.inputrc $HOME/.inputrc

# Machine specific
if [[ -e $config/machines/`hostname` ]]; then
    for file in `ls -A1 "$config/machines/\`hostname\`/"`; do
	$link $config/machines/`hostname`/$file $HOME/$file
    done
fi

case `uname -a` in		# prepare Windows
    *Cygwin* )
	$hardlink "$config/../scripts/windows/rc.compat.bat" \
	    "/cygdrive/c/Users/`whoami`/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/" ;;
    *ARCH* )			# prepare Arch Linux
	$link $config/pacman.conf /etc/pacman.conf
esac
