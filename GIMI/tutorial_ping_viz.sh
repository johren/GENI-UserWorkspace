#!/bin/sh
perl R_script_ping.pl $1
perl html_script.pl $1
expect -c 'spawn sudo cp oml.html /var/www; expect password; send "gec14user\n"; interact'
while true
do
 rm -f $1.sq3
 iget -f $1.sq3
 R -f R_script_ping_viz.r
 ./expect_script.sh $1
 # expect -c 'spawn sudo cp ${NAME}.jpg /var/www/html; expect password; send "\$tr3am\n"; interact'
 sleep 15
done
