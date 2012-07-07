#!/usr/bin/expect
set file [lindex $argv 0]
spawn sudo cp ${file}.png /var/www/
expect "password:"
send "gec14user\n";
interact
