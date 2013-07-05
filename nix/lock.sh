#!/bin/bash

# This script locks the screen via xscreensaver daemon
[[ -z `xscreensaver-command -time 2>/dev/null` ]] && xscreensaver -no-splash &
xscreensaver-command --activate
