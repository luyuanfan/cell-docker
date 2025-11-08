#!/bin/bash

CONFIG=$(echo "$CONFIG64" | base64 -d)

MCC=$(jq -r ".network.mcc" <<< "$CONFIG")
MNC=$(jq -r ".network.mnc" <<< "$CONFIG")
APN=$(jq -r ".network.apn" <<< "$CONFIG")
USRP=$(jq -r ".ran.usrp" <<< "$CONFIG")
MIMO=$(jq -r ".ran.mimo" <<< "$CONFIG")
NUM_UES=$(jq -r ".core.num_ues" <<< "$CONFIG")
IMSI=$(jq -r ".core.imsi" <<< "$CONFIG")
KEY=$(jq -r ".core.key" <<< "$CONFIG")
OPC=$(jq -r ".core.opc" <<< "$CONFIG")
TYPE=1

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# #############
# #  MongoDB  #
# #############

# # if mongo is not running, execute it in the background
# mkdir -p /data/db
# chown -R mongodb:mongodb /data/db || true

# if ! nc -z localhost 27017; then
#     echo "Starting MongoDB manually..."
# 	mongod --fork --logpath /mongod.log
# fi

##########
#  Core  #
##########

# wait until mongo DB gets initialized
# while true;
# do
# 	nc -zvv localhost 27017 > /dev/null 2>&1
# 	if [ $? -eq 0 ]; then
# 		break
# 	else
# 		echo "Waiting for MongoDB..."
# 		sleep 1
# 	fi
# done

# # populate core database
# add_ue_with_apn {imsi key opc apn}
# type {imsi type}: changes the PDN-Type of the first PDN: 1 = IPv4, 2 = IPv6, 3 = IPv4v6"
# for i in $(seq -f "%010g" 1 $NUM_UES)
# do
# 	/open5gs/misc/db/open5gs-dbctl reset
# 	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $IMSI $KEY $OPC $APN
# 	/open5gs/misc/db/open5gs-dbctl type $IMSI $TYPE
# done

# /open5gs/misc/db/open5gs-dbctl reset
# /open5gs/misc/db/open5gs-dbctl add_ue_with_apn $IMSI $KEY $OPC $APN
# /open5gs/misc/db/open5gs-dbctl type $IMSI $TYPE

# sed -i "s/NETWORK_MCC/$MCC/g" amf.yaml
# sed -i "s/NETWORK_MNC/$MNC/g" amf.yaml
# sed -i "s/NETWORK_APN/$APN/g" amf.yaml
# sed -i "s/NETWORK_MCC/$MCC/g" nrf.yaml
# sed -i "s/NETWORK_MNC/$MNC/g" nrf.yaml
# sed -i "s/NETWORK_APN/$APN/g" smf.yaml

# echo "Running 5G SA Core Network"

# /open5gs/install/bin/open5gs-nrfd -c /nrf.yaml &        # discover other core services
# /open5gs/install/bin/open5gs-scpd &                     # enable indirect communication           
# # /open5gs/install/bin/open5gs-seppd &                  # roaming security
# /open5gs/install/bin/open5gs-amfd -c /amf.yaml &        # subscriber authentication
# /open5gs/install/bin/open5gs-smfd -c /smf.yaml &        # session management
# /open5gs/install/bin/open5gs-upfd -c /upf.yaml &        # transport data packets between gnb and external WAN
# /open5gs/install/bin/open5gs-ausfd &                    # next three do sim authentication and hold user profile
# /open5gs/install/bin/open5gs-udmd & 
# /open5gs/install/bin/open5gs-udrd &
# /open5gs/install/bin/open5gs-pcfd &                     # charging & enforcing subscriber policies
# /open5gs/install/bin/open5gs-nssfd &                    # allow selecting network slice
# /open5gs/install/bin/open5gs-bsfd &                     # binding support function
# /open5gs/install/bin/open5gs-mmed &                     # below are all LTE services
# /open5gs/install/bin/open5gs-sgwcd & 
# /open5gs/install/bin/open5gs-sgwud & 
# /open5gs/install/bin/open5gs-hssd & 
# /open5gs/install/bin/open5gs-pcrfd &

# sleep 1

############
#  RAN 5G  #
############

sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
sed -i "s/USRP_ID/$USRP/g" gnb.yml
if [[ ${MIMO,,} == "yes" ]]; then 
	TRANSMISSION_MODE=4
	NUM_PORTS=2
else
	TRANSMISSION_MODE=1
	NUM_PORTS=1
fi
sed -i "s/TRANSMISSION_MODE/$TRANSMISSION_MODE/g" gnb.yml
sed -i "s/NUM_PORTS/$NUM_PORTS/g" gnb.yml

chrt --rr 99 gnb -c gnb.yml