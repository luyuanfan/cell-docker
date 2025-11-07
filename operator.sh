#!/bin/bash
set -e

DEV="ogstun"

if [ "$#" -ne 1 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: .$0 config.json"
    exit 1
fi

ip tuntap del name ogstun mode tun
iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
echo "$DEV does not exist, creating..."
ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
ip link set dev ogstun up
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

# ip link set docker0 mtu 3000
sysctl -w net.ipv4.ip_forward=1
ufw disable

./docker/scripts/srsran_performance

docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -v /proc:/proc -e CONFIG64="$(base64 $1)" jasminetest ./initOperator.sh
# docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -v /proc:/proc -e CONFIG64="$(base64 $1)" luyuanfan/gnb:b200 ./initOperator.sh
# docker run -ti --privileged --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/gnb:b200 ./initOperator.sh
