#!/usr/bin/expect

set timeout 320
set net_id [lindex $argv 0]
set ip [lindex $argv 1]
set command [lindex $argv 2]

spawn ssh -i $net_id -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin\@$ip

expect "Welcome"
send "exit\r"

expect "admin$ "
send "su root\r"

expect "Password:"
send "ShoreTel\r"

expect "/root#"
send "$command\r"

expect "/root#"
send "exit\r"
expect "admin$ "
send "exit\r"

puts "\n"
interact
