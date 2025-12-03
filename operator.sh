#!/bin/bash
set -e

if [ "$#" -ne 0 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: $0"
    exit 1
fi

echo "Deleting TUN device ogstun nd creating a new one..."
# delete existing tun device and associated NAT rules 
if ip link show ogstun &>/dev/null; then
    ip tuntap del name ogstun mode tun
    iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
fi
# create another one fresh
ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip link set dev ogstun up
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

# enable ipv4 forwarding, disable firewall, run srsran system tuning script
sysctl -w net.ipv4.ip_forward=1
ufw disable
./docker/scripts/srsran_performance

# run container in network host mode with highest privilege
# docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -v /proc:/proc -e CONFIG64="$(base64 $1)" jasminetest2 ./initOperator.sh
docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -v /proc:/proc --env-file .env jasminetest2 ./initOperator.sh