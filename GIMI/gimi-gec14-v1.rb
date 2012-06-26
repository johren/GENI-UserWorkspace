defProperty('source1', "node1", "ID of a resource")
defProperty('source2', "node2", "ID of a resource")
defProperty('sink', "node0", "ID of a resource")
defProperty('sendrate', '10M', "Bitrate (bit/s) for the Senders")
defProperty('udpPort', 6000, "Port to use")

defPrototype("iperf_udp_sender") do |p| 
  p.name = "Iperf UDP Sender" 
  p.description = "A traffic generator using Iperf to send UDP packet"
  p.defProperty('udp', 'Set traffic transport to UDP', true)
  p.defProperty('target', 'Host to send the traffic to', property.sink)
  p.defProperty('port', 'Port to send the traffic to', property.udpPort)
  p.defProperty('bandwidth', 'Bandwidth to send at in bit/sec [KM]', property.sendrate)
  p.addApplication("iperf_app") do |a|
    a.bindProperty('client', 'target')
    a.bindProperty('port', 'port')
    a.bindProperty('udp', 'udp')
    a.bindProperty('bandwidth', 'bandwidth')
  end
end

defGroup('Sender1', property.source1) do |node|
  node.addPrototype 'iperf_udp_sender'
  node.addPrototype 'system_monitor'
end

defGroup('Sender2', property.source2) do |node|
  node.addPrototype 'iperf_udp_sender'
  node.addPrototype 'system_monitor'
end

defGroup('Receiver', property.sink) do |node|
  node.addApplication("iperf_app") do |app|
    app.setProperty('udp', true)
    app.setProperty('server', true)
    app.setProperty('port', property.udpPort)
    app.setProperty('reportstyle', 'o')
    app.setProperty('interval', 1)
    app.measure('connection', :samples => 1)
    app.measure('transfer', :samples => 1)
    app.measure('losses', :samples => 1)
  end
  node.addPrototype 'system_monitor'
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  wait 10
  group('All').startApplications
  info "Starting the Receiver"
  group('Receiver').startApplications
  wait 5
  info "Starting Sender 1"
  group('Sender1').startApplications
  wait 15
  info "Starting Sender 2"
  group('Sender2').startApplications
  wait 15
  info "Stopping Sender 2"
  group('Sender2').stopApplications
  wait 15
  info "Stopping Sender 1"
  group('Sender1').stopApplications

  allGroups.stopApplications
  wait 5
  Experiment.done
end

