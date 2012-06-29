#!/bin/sh
while true
do
  omf-5.4 exec --no-cmc tcp_iperf.rb -- --source1 nodeA --sink nodeC
  sleep 5
done
