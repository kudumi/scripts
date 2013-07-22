#!/bin/bash

# Customize these
mailboxes="Inbox rss"
none="."			# no mail signal
some="!"			# some mail signal

# variables
output=""
mailcheckrc="$HOME/.mailcheckrc"
mailcheck_prefix="imap://esc@ericcrosson.com@imap.secureserver.net:143/"
separator=" "			# formatting

for box in ${mailboxes}; do

    flag=${none}
    echo ${mailcheck_prefix}${box} > ${mailcheckrc}
    [[ `mailcheck | grep new` ]] && flag=${some} # new mail indicator

    output="${output}${flag}${separator}${box}${Color_Off}${separator}"
done

echo -e ${output}
