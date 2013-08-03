#!/bin/bash

auth="$HOME/.imapfilter/centtech.gpg"

function ctrl-c() { nightman return ${auth}; }
trap ctrl-c SIGINT		# Trap exits and interrupts to
trap ctrl-c EXIT		# avoid leaving behind secrets

nightman checkout ${auth}

imapfilter -c $HOME/Dropbox/config/.imapfilter/centtech.rules.lua
