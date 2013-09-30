#!/usr/bin/env bash

auth="$HOME/.imapfilter/esc.gpg"

function ctrl_c() { nightman return ${auth}; }
trap ctrl_c SIGINT		# Trap exits and interrupts to
trap ctrl_c EXIT		# avoid leaving behind secrets

nightman checkout ${auth}

imapfilter -c $HOME/Dropbox/config/.imapfilter/archive.sms.lua
