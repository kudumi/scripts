#!/usr/bin/env bash

if [[ -z `which mailcheck 2>/dev/null` ]]; then
    echo "mailcheck not installed"
    exit 1
elif [[ ! -e $HOME/.netrc ]]; then
    echo "logged out"
    exit 1
fi

# Customize these
mailboxes="Inbox rss"
workboxes="Inbox"

none="¤"			# no mail signal
some="√"			# some mail signal

# variables
output=""
mailcheckrc="$HOME/.mailcheckrc"
mail_prefix="imap://esc@ericcrosson.com@imap.secureserver.net:143/"
work_prefix="imap://ecrosson@zmail0.centtech.com@zmail0.centtech.com:143/"
separator=" "			# formatting

for box in ${mailboxes}; do

    flag=${none}
    echo ${mail_prefix}${box} > ${mailcheckrc}
    [[ `mailcheck | grep new` ]] && flag=${some} # new mail indicator

    output="${output}${flag}${separator}${box}${Color_Off}${separator}"
done

#[[ ${workboxes} && ${#output} != 0 ]] && output="${output} ~ "

for box in ${workboxes}; do

    flag=${none}
    echo ${work_prefix}${box} > ${mailcheckrc}
    [[ `mailcheck | grep new` ]] && flag=${some} # new mail indicator

    output="${output}${flag}${separator}${box}${Color_Off}${separator}"
done

rm ${mailcheckrc}
echo -e ${output}
