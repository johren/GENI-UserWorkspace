defProperty('source1', 'omf.nicta.node11', 'ID of a resource')
#defProperty('source2', 'omf.orca.node2', 'ID of a resource')
defProperty('sink', 'omf.nicta.node13', 'ID of a resource')
#defProperty('sendrate', '100M', 'Bitrate (bit/s) for the Senders')
#defProperty('tcpPort', 6000, 'Port to use')
#defProperty('runtime',40,'Time in second for the experiment is to run')

defProperty('target1', '192.168.3.12', 'First IP address of the sink')
defProperty('target2', '192.168.2.12', 'Second IP address of the sink')

defGroup('Sender1', property.source1) do |n|  
  #p.defProperty('port', 'Port to send the traffic to', property.tcpPort)
  #p.defProperty('bandwidth', 'Bandwidth to send at in bit/sec [KM]', property.sendrate)
  n.addApplication('iperf-5.4') do |a|
    a.setProperty('client', property.target1)
    a.setProperty('time', 300)
    a.setProperty('interval','10')
    a.setProperty('reportstyle', 'o')
    a.measure('connection', :samples => 1)
    a.measure('transfer', :samples => 1)
    a.measure('losses', :samples => 1)

  end
end

defGroup('Sender2', property.source1) do |n|
  #p.defProperty('port', 'Port to send the traffic to', property.tcpPort)
  #p.defProperty('bandwidth', 'Bandwidth to send at in bit/sec [KM]', property.sendrate)
  n.addApplication('iperf-5.4') do |a|
    a.setProperty('client', property.target2)
    a.setProperty('time', 300)
    a.setProperty('interval','10')
    a.setProperty('reportstyle', 'o')
    a.measure('connection', :samples => 1)
    a.measure('transfer', :samples => 1)
    a.measure('losses', :samples => 1)

  end
end

defGroup('Receiver', property.sink) do |node|
  node.addApplication('iperf-5.4') do |app|
    #app.setProperty('tcp', false)
    app.setProperty('server', true)
    #app.setProperty('port', property.tcpPort)
  #  app.setProperty('reportstyle', 'o')
    #app.setProperty('time', 50)
    #app.setProperty('interval', '10')
    #app.measure('connection', :samples => 1)
    #app.measure('transfer', :samples => 1)
    #app.measure('losses', :samples => 1)
  end
#  node.addPrototype 'system_monitor'
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  wait 1
#  group('All').startApplications
  info 'Starting the Receiver'
  group('Receiver').startApplications
  wait 5
  info 'Starting Sender 1'
  group('Sender1').startApplications
  wait 1
  info 'Starting Sender 2'
  group('Sender2').startApplications
  wait 315
  info 'Stopping Sender 2'
  group('Sender2').stopApplications
  wait 5
  info 'Stopping Sender 1'
  group('Sender1').stopApplications

  allGroups.stopApplications
  wait 5
  Experiment.done
end
