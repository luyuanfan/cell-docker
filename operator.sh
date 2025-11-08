#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: .$0 config.json"
    exit 1
fi

# delete existing tun device and associated NAT rules 
if ip link show ogstun &>/dev/null; then
    echo "Deleting TUN device ogstun..."
    ip tuntap del name ogstun mode tun
fi
if iptables -t nat -C POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE &>/dev/null; then
    echo "Deleting NAT rules for ogstun..."
    iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
fi
# create another one fresh
echo "Re-creating ogstun and associated NAT rules..."
ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip link set dev ogstun up
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

# enable ipv4 forwarding, disable firewall, run srsran system tuning script
sysctl -w net.ipv4.ip_forward=1
ufw disable
./docker/scripts/srsran_performance

export CONFIG64=$(base64 $1)
docker compose logs

# run container in network host mode with highest privilege
# docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -v /proc:/proc -e CONFIG64="$(base64 $1)" jasminetest2 ./initOperator.sh