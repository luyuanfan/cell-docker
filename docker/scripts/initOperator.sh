#!/bin/bash

CONFIG=$(echo "$CONFIG64" | base64 -d)

# Parse operator configuration
MCC=$(jq -r ".network.mcc" <<< "$CONFIG")
MNC=$(jq -r ".network.mnc" <<< "$CONFIG")
APN=$(jq -r ".network.apn" <<< "$CONFIG")
USRP=$(jq -r ".ran.usrp" <<< "$CONFIG")
NUM_UES=$(jq -r ".core.num_ues" <<< "$CONFIG")
KEY=$(jq -r ".core.key" <<< "$CONFIG")
OPC=$(jq -r ".core.opc" <<< "$CONFIG")
NUM_PRBS=$(jq -r ".ran.prbs" <<< "$CONFIG")
MIMO=$(jq -r ".ran.mimo" <<< "$CONFIG")
DL_EARFCN=$(jq -r ".ran.dl_earfcn" <<< "$CONFIG")

#############
# Time Zone #
#############

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" > /etc/timezone

#############
#  MongoDB  #
#############
# # If mongo is not running, execute it in the background
# mkdir -p /data/db
# chown -R mongodb:mongodb /data/db || true

# nc -zvv localhost 27017 > /dev/null 2>&1
# if [ $? -ne 0 ]; then
# 	mongod --fork --logpath /mongod.log
# fi

mkdir -p /data/db
chown -R mongodb:mongodb /data/db || true
echo "Starting MongoDB manually...??"

# If MongoDB is not running, start it manually
if ! nc -z localhost 27017; then
    echo "Starting MongoDB manually...!!"
    # mongod --dbpath /data/db --logpath /mongod.log --bind_ip_all --fork
	mongod --fork --logpath /mongod.log
    # sleep 3
fi

##########
#  Core  #
##########

# Create TUN device
ip tuntap add name ogstun mode tun
ip addr add 10.45.0.1/16 dev ogstun
# ip addr add 2001:db8:cafe::1/48 dev ogstun
ip link set ogstun up

# Connect core to the internet
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE

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
for i in $(seq -f "%010g" 1 $NUM_UES)
do
	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $MCC$MNC$i $KEY $OPC $APN
	/open5gs/misc/db/open5gs-dbctl type 1
done

# Get main interface IP
# Modify the Core configuration file 
sed -i "s/NETWORK_MCC/$MCC/g" config.yaml
sed -i "s/NETWORK_MNC/$MNC/g" config.yaml


# Run Open5GS
/open5gs/build/tests/app/epc -c /config.yaml > core.log &
echo "Running 4G Core Network"
sleep 1

#########
#  RAN  #
#########
sed -i "s/NETWORK_MCC/$MCC/g" enb.conf
sed -i "s/NETWORK_MNC/$MNC/g" enb.conf
sed -i "s/USRP_ID/$USRP/g" enb.conf
sed -i "s/NUM_PRBS/$NUM_PRBS/g" enb.conf
if [[ ${MIMO,,} == "yes" ]]; then 
	TRANSMISSION_MODE=4
	NUM_PORTS=2
else
	TRANSMISSION_MODE=1
	NUM_PORTS=1
fi
sed -i "s/TRANSMISSION_MODE/$TRANSMISSION_MODE/g" enb.conf
sed -i "s/NUM_PORTS/$NUM_PORTS/g" enb.conf
sed -i "s/#DL_EARFCN/dl_earfcn = $DL_EARFCN/g" enb.conf

#taskset -c $CPU_IDS srsenb --rf.device_name=uhd --rf.device_args="serial=$USRP" enb.conf
srsenb enb.conf