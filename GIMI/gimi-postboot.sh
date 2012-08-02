#!/bin/bash

SLICENAME=$1
NODEID=$2
echo "hostname ${SLICENAME}-${NODEID}"
hostname ${SLICENAME}-${NODEID}
apt-get update

curl https://pkg.mytestbed.net/ubuntu/oneiric/oml2-iperf_2.0.5-1ubuntu5_amd64.deb -o /root/iperf.deb
dpkg -i /root/iperf.deb

if [ "${NODEID}" = "NodeA" ]; then
    route add -net 192.168.2.0 netmask 255.255.255.0  gw 192.168.1.11
elif [ "${NODEID}" = "NodeB" ]; then
    echo 1 >  /proc/sys/net/ipv4/ip_forward
elif [ "${NODEID}" = "NodeC" ]; then
    route add -net 192.168.1.0 netmask 255.255.255.0  gw 192.168.2.11
fi

curl http://emmy9.casa.umass.edu/pingWrap.rb -o /root/pingWrap.rb
chmod +x /root/pingWrap.rb
gem install oml4r

omf_create_psnode-5.4 emmy9.casa.umass.edu mkslice ${SLICENAME} ${SLICENAME}-${NODEID}

cd /
curl http://emmy8.casa.umass.edu/enrolled.patch -o enrolled.patch
patch -p1 < enrolled.patch

curl http://emmy8.casa.umass.edu/omf-resctl.yaml -o /etc/omf-resctl-5.4/omf-resctl.yaml
perl -i.bak -pe "s/\:slice\:/\:slice\: ${SLICENAME}/g" /etc/omf-resctl-5.4/omf-resctl.yaml

/etc/init.d/omf-resctl-5.4 restart

