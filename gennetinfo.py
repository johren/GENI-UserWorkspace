#!/usr/bin/python

from xml.etree import ElementTree
import sys

if len(sys.argv) != 3:
   print "gennetinfo.py <manifest> <namespace>"
   print "Example:  gennetinfo.py johrengimi0727-rspec-*.xml  http://www.geni.net/resources/rspec/3"
   sys.exit(1)

filename = sys.argv[1]
ns = sys.argv[2]

if len(ns) == 0:
   sys.exit(1)

try:
   tree = ElementTree.parse(filename)
   rootElement = tree.getroot()

   nodeList = rootElement.findall(".//{%s}node" % ns)
   for node in nodeList:
       name=node.attrib["client_id"]
       login=node.find("./{%s}services/{%s}login" % (ns,ns))
       if login is not None:
           hostname=login.attrib["hostname"]
           port=login.attrib["port"]
#       print name + " login " + hostname + ":" + port
       print name + ":" + hostname
#       interfaceList = node.findall("./{%s}interface" % ns)
#       for intf in interfaceList:
#           ifname=intf.attrib["client_id"]
#           ip=intf.find("./{%s}ip" % ns)
#           ipaddr=ip.attrib["address"] 
#           print name + " interface " + ifname + " " + ipaddr 
   
except Exception, inst:
       print "Unexpected error opening %s: %s" % (filename, inst)


