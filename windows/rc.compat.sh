#export DISPLAY=:0		# for xrdb
xrdb ~/.Xresources

screen -wipe	  # Wipe dead screen sessions (leftover from shutdown)
screen -dm mon	  # create initial screen- use xmon

emacs --daemon	  # Start emacs daemon

apt-cyg update	  # Update cygwin library
