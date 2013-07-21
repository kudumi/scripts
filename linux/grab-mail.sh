#!/bin/bash

getmail -lnq
[[ `ls -1 ~/mail/new/` ]] && notify-send -u normal -a xterm -c mail "Mailbox has a new inhabitant" "`ls -1 ~/mail/new/ | wc -l` new messages"
