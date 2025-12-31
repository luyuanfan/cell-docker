#!/bin/bash
set -e

if [ "$#" -gt 1 ] ; then
    echo "USE: sudo ./operator.sh"
    echo "Intra-gNB Handover: sudo ./operator.sh -h"
    exit 1
fi

# delete existing tun devices (ogstun and ogstun2) and associated NAT rules 
if ip link show ogstun &>/dev/null; then
    ip tuntap del name ogstun mode tun
    echo "Deleted TUN device ogstun"
fi
if ip link show ogstun2 &>/dev/null; then
    ip tuntap del name ogstun2 mode tun
    echo "Deleted TUN device ogstun2"
fi
if iptables -t nat -C POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE &>/dev/null; then
    iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
    echo "Deleted NAT rules for ogstun"
fi
if iptables -t nat -C POSTROUTING -s 10.45.0.0/16 ! -o ogstun2 -j MASQUERADE &>/dev/null; then
    iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun2 -j MASQUERADE
    echo "Deleted NAT rules for ogstun2"
fi

# create new tun devices from fresh
ip tuntap add name ogstun mode tun
ip tuntap add name ogstun2 mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip addr add 10.46.0.1/16 dev ogstun2
ip link set dev ogstun up
ip link set dev ogstun2 up
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.46.0.0/16 ! -o ogstun2 -j MASQUERADE
echo "Re-created ogstun ogstun2 and associated NAT rules"

# enable ipv4 forwarding, disable firewall, run srsran system tuning script
sysctl -w net.ipv4.ip_forward=1
ufw disable
./docker/scripts/srsran_performance

if [ "$1" = "-h" ]; then 
    docker compose -f compose-handover.yaml up --build
else
    docker compose up --build
fi
echo "Experiment ended" 