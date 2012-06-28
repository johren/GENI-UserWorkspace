defProperty('source1', "omf.orca.node1", "ID of a resource")
#defProperty('source2', "omf.orca.node2", "ID of a resource")
defProperty('sink', "omf.orca.node3", "ID of a resource")
#defProperty('sendrate', '100M', "Bitrate (bit/s) for the Senders")
#defProperty('tcpPort', 6000, "Port to use")
#defProperty('runtime',40,"Time in second for the experiment is to run")


defPrototype("iperf_tcp_sender_1") do |p| 
  p.name = "Iperf TCP Sender" 
  p.description = "A traffic generator using Iperf to send TCP packet"
 # p.defProperty('tcp', 'Set traffic transport to UDP', false)
  p.defProperty('target', 'Host to send the traffic to', "192.168.3.12")
  #p.defProperty('port', 'Port to send the traffic to', property.tcpPort)
  #p.defProperty('bandwidth', 'Bandwidth to send at in bit/sec [KM]', property.sendrate)
  p.addApplication("iperf_app") do |a|
    a.bindProperty('client', 'target')
    a.bindProperty('time', 300)
    #a.bindProperty('interval',10)
    #a.bindProperty('port', 'port')
    #a.bindProperty('tcp', 'tcp')
    #a.bindProperty('bandwidth', 'bandwidth')
  end
end

defPrototype("iperf_tcp_sender_2") do |p|
  p.name = "Iperf TCP Sender"
  p.description = "A traffic generator using Iperf to send TCP packet"
 # p.defProperty('tcp', 'Set traffic transport to UDP', false)
  p.defProperty('target', 'Host to send the traffic to', "192.168.2.12")
  #p.defProperty('port', 'Port to send the traffic to', property.tcpPort)
  #p.defProperty('bandwidth', 'Bandwidth to send at in bit/sec [KM]', property.sendrate)
  p.addApplication("iperf_app") do |a|
    a.bindProperty('client', 'target') 
    a.bindProperty('time', 300)
    #a.bindProperty('interval',10)
   #a.bindProperty('port', 'port')
    #a.bindProperty('tcp', 'tcp')
    #a.bindProperty('bandwidth', 'bandwidth')
  end
end


defGroup('Sender1', property.source1) do |node|
  node.addPrototype 'iperf_tcp_sender_1'

#node.addPrototype 'system_monitor'
end

defGroup('Sender2', property.source1) do |node|
  node.addPrototype 'iperf_tcp_sender_2'
 # node.addPrototype 'system_monitor'
end

defGroup('Receiver', property.sink) do |node|
  node.addApplication("iperf_app") do |app|
    #app.setProperty('tcp', false)
    app.setProperty('server', true)
    #app.setProperty('port', property.tcpPort)
    app.setProperty('reportstyle', 'o')
    #app.setProperty('time', 50)
    app.setProperty('interval', 10)
    app.measure('connection', :samples => 1)
    app.measure('transfer', :samples => 1)
    app.measure('losses', :samples => 1)
  end
#  node.addPrototype 'system_monitor'
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  wait 10
#  group('All').startApplications
  info "Starting the Receiver"
  group('Receiver').startApplications
  wait 5
  info "Starting Sender 1"
  group('Sender1').startApplications
  wait 1
  info "Starting Sender 2"
  group('Sender2').startApplications
  wait 315
  info "Stopping Sender 2"
  group('Sender2').stopApplications
  wait 5
  info "Stopping Sender 1"
  group('Sender1').stopApplications

  allGroups.stopApplications
  wait 5
  Experiment.done
end

