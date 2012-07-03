#!/usr/bin/expect
set file [lindex $argv 0]
spawn sudo cp ${file}1.jpg /var/www/html
expect "password:"
send "\$tr3am\n";
interact

spawn sudo cp ${file}2.jpg /var/www/html
expect "password:"
send "\$tr3am\n";
interact

