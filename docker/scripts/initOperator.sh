#!/bin/bash

CONFIG=$(echo "$CONFIG64" | base64 -d)

# Parse operator configuration
MCC=$(jq -r ".network.mcc" <<< "$CONFIG")
MNC=$(jq -r ".network.mnc" <<< "$CONFIG")
APN=$(jq -r ".network.apn" <<< "$CONFIG")
USRP=$(jq -r ".ran.usrp" <<< "$CONFIG")
USRP_IP=$(jq -r ".ran.usrp_ip" <<< "$CONFIG")
BANDWIDTH=$(jq -r ".ran.bandwidth" <<< "$CONFIG")
MIMO=$(jq -r ".ran.mimo" <<< "$CONFIG")
DL_EARFCN=$(jq -r ".ran.dl_earfcn" <<< "$CONFIG")
NUM_UES=$(jq -r ".core.num_ues" <<< "$CONFIG")
IMSI=$(jq -r ".core.imsi" <<< "$CONFIG")
KEY=$(jq -r ".core.key" <<< "$CONFIG")
OPC=$(jq -r ".core.opc" <<< "$CONFIG")
TYPE=1

#############
# Time Zone #
#############

# ln -sf /usr/share/zoneinfo/Etc/Universal /etc/localtime
echo "Etc/Universal" > /etc/timezone

#############
#  MongoDB  #
#############
# If mongo is not running, execute it in the background

mkdir -p /data/db
chown -R mongodb:mongodb /data/db || true

if ! nc -z localhost 27017; then
    echo "Starting MongoDB manually..."
	mongod --fork --logpath /mongod.log
fi

##########
#  Core  #
##########

# Create TUN device
# ip tuntap add name ogstun mode tun
# ip addr add 10.45.0.1/16 dev ogstun
# # ip addr add 2001:db8:cafe::1/48 dev ogstun
# ip link set ogstun up

# Connect core to the internet
# sysctl -w net.ipv4.ip_forward=1
# # sysctl -w net.ipv6.conf.all.forwarding=1
# iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

# iptables -I INPUT -i ogstun -j ACCEPT
# iptables -I INPUT -s 10.45.0.0/16 -j DROP

# ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE

# Wait until mongo DB gets initialized
while true;
do
	nc -zvv localhost 27017 > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		break
	else
		echo "Waiting for MongoDB..."
		sleep 1
	fi
done

# Populate core database
# add_ue_with_apn {imsi key opc apn}
# type {imsi type}: changes the PDN-Type of the first PDN: 1 = IPv4, 2 = IPv6, 3 = IPv4v6"
# for i in $(seq -f "%010g" 1 $NUM_UES)
# do
# 	/open5gs/misc/db/open5gs-dbctl reset
# 	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $IMSI $KEY $OPC $APN
# 	/open5gs/misc/db/open5gs-dbctl type $IMSI $TYPE
# done

/open5gs/misc/db/open5gs-dbctl reset
/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $IMSI $KEY $OPC $APN
/open5gs/misc/db/open5gs-dbctl type $IMSI $TYPE

# Get main interface IP
# Modify the Core configuration file 
sed -i "s/NETWORK_MCC/$MCC/g" amf.yaml
sed -i "s/NETWORK_MNC/$MNC/g" amf.yaml
sed -i "s/NETWORK_MCC/$MCC/g" nrf.yaml
sed -i "s/NETWORK_MNC/$MNC/g" nrf.yaml

# Run Open5GS
echo "Running 5G SA Core Network"
# /open5gs/build/tests/app/5gc -c /core.yaml > core.log &
mkdir core

# discover other core services
/open5gs/install/bin/open5gs-nrfd -c /nrf.yaml > /core/nrf.log &
# enable indirect communication
/open5gs/install/bin/open5gs-scpd & #> /core/scp.log &
# roaming security
# /open5gs/install/bin/open5gs-seppd -c /open5gs/install/etc/open5gs/sepp1.yaml > /core/sepp.log &
# subscriber authentication
/open5gs/install/bin/open5gs-amfd -c /amf.yaml > /core/amf.log &
# session management
/open5gs/install/bin/open5gs-smfd -c /smf.yaml > /core/smf.log & #> /core/smf.log &
# transport data packets between gnb and external WAN, connect to SMF
/open5gs/install/bin/open5gs-upfd -c /upf.yaml > /core/upf.log &
# next three do sim authentication and hold user profile
/open5gs/install/bin/open5gs-ausfd & #> /core/ausf.log &
/open5gs/install/bin/open5gs-udmd & #> /core/udm.log &
/open5gs/install/bin/open5gs-udrd & #> /core/udr.log &
# charging & enforcing subscriber policies
/open5gs/install/bin/open5gs-pcfd & #> /core/pcf.log &
# allow selecting network slice
/open5gs/install/bin/open5gs-nssfd & #> /core/nssf.log &
# Binding Support Function
/open5gs/install/bin/open5gs-bsfd & #> /core/bsf.log &
# don't really care these are LTE services
/open5gs/install/bin/open5gs-mmed & #> /core/mme.log &
/open5gs/install/bin/open5gs-sgwcd & #> /core/sgwc.log &
/open5gs/install/bin/open5gs-sgwud & #> /core/sgwu.log &
/open5gs/install/bin/open5gs-hssd & #> /core/hss.log &
/open5gs/install/bin/open5gs-pcrfd & #> /core/pcrf.log &

# /open5gs/build/tests/app/epc -c /core.yaml > core.log &
# echo "Running 4G Core Network"
sleep 1

# ############
# #  RAN 4G  #
# ############
# sed -i "s/NETWORK_MCC/$MCC/g" enb.conf
# sed -i "s/NETWORK_MNC/$MNC/g" enb.conf
# sed -i "s/USRP_ID/$USRP/g" enb.conf
# sed -i "s/USRP_IP/$USRP_IP/g" enb.conf
# sed -i "s/NUM_PRBS/$NUM_PRBS/g" enb.conf
# if [[ ${MIMO,,} == "yes" ]]; then 
# 	TRANSMISSION_MODE=4
# 	NUM_PORTS=2
# else
# 	TRANSMISSION_MODE=1
# 	NUM_PORTS=1
# fi
# sed -i "s/TRANSMISSION_MODE/$TRANSMISSION_MODE/g" enb.conf
# sed -i "s/NUM_PORTS/$NUM_PORTS/g" enb.conf
# sed -i "s/#DL_EARFCN/dl_earfcn = $DL_EARFCN/g" enb.conf

# #taskset -c $CPU_IDS srsenb --rf.device_name=uhd --rf.device_args="serial=$USRP" enb.conf
# srsenb enb.conf

############
#  RAN 5G  #
############

chmod 700 srsran_performance
./srsran_performance # Tune system

sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
sed -i "s/USRP_ID/$USRP/g" gnb.yml
sed -i "s/USRP_IP/$USRP_IP/g" gnb.yml
sed -i "s/BANDWIDTH/$BANDWIDTH/g" gnb.yml
if [[ ${MIMO,,} == "yes" ]]; then 
	TRANSMISSION_MODE=4
	NUM_PORTS=2
else
	TRANSMISSION_MODE=1
	NUM_PORTS=1
fi
sed -i "s/TRANSMISSION_MODE/$TRANSMISSION_MODE/g" gnb.yml
sed -i "s/NUM_PORTS/$NUM_PORTS/g" gnb.yml
sed -i "s/DL_EARFCN/$DL_EARFCN/g" gnb.yml

#taskset -c $CPU_IDS srsenb --rf.device_name=uhd --rf.device_args="serial=$USRP" enb.conf
# srsenb enb.conf
chrt -rr 99 gnb -c gnb.yml