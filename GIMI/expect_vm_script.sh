#!/usr/bin/expect
spawn sudo cp experiment.rb /usr/share/omf-expctl-5.4/omf-expctl/
expect "password:"
send "gec14user\n";
interact

spawn sudo cp omf-expctl.yaml /etc/omf-expctl-5.4/
expect "password:"
send "gec14user\n";
interact

