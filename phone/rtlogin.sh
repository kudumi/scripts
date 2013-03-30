#!/usr/bin/expect

# To customize, mind the priv_id to phone key and call as follows:
# ${0##*/} <ip_of_phone>

set username ecrosson
set priv_id "/home/$username/.ssh/hq_rsa"

set timeout 20
set ip [lindex $argv 0]
set user "admin"

spawn ssh -i $priv_id -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user\@$ip

expect "Welcome"
send "exit\r"

expect "admin$ "
send "su root\r"

expect "Password:"
send "ShoreTel\r"

expect "/root# "

interact
