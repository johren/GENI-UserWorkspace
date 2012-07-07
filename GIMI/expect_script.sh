#!/usr/bin/expect
set file [lindex $argv 0]
spawn sudo cp ${file}.png /var/www/html
expect "password:"
send "\$tr3am\n";
interact
