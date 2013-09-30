#!/usr/bin/env bash

name=mailer
screen -wipe			# clear out stale screens

if [[ `screen -ls | grep "[0-9]*.$name"`  ]]; then
    screen -x $name
else
    screen -S $name -c $HOME/Dropbox/config/screen/.screenrc.mail
fi
