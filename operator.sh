#!/bin/bash
set -e

if [ "$#" -gt 1 ] ; then
    echo "USE: sudo ./operator.sh"
    exit 1
fi

# delete existing tun devices (ogstun and ogstun2) and associated NAT rules 
if ip link show ogstun &>/dev/null; then
    ip tuntap del name ogstun mode tun
    echo "Deleted TUN device ogstun"
fi
if iptables -t nat -C POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE &>/dev/null; then
    iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
    echo "Deleted NAT rules for ogstun"
fi

# create new tun devices from fresh
ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip link set dev ogstun up
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
echo "Re-created ogstun and associated NAT rules"

# enable ipv4 forwarding, disable firewall, run srsran system tuning script
sysctl -w net.ipv4.ip_forward=1
ufw disable
./docker/scripts/srsran_performance

docker compose up --build

echo "Experiment ended" 