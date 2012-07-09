#!/bin/sh
while true
do
  omf-5.4 exec --no-cmc -S gimiXX-tutorial tcp_iperf.rb -- --source1 gimiXX-tutorial-nodeA --sink gimiXX-tutorial-nodeC
  sleep 5
done
