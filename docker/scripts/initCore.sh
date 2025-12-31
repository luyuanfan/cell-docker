#!/bin/bash

PAD="00000000"

echo "Starting Open5GS core services"

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

#############
#  MongoDB  #
#############

# if mongo is not running, execute it in the background
mkdir -p /data/db
chown -R mongodb:mongodb /data/db || true

if ! nc -z localhost 27017; then
    echo "Starting MongoDB manually..."
	mongod --fork --logpath /mongod.log
fi

##########
#  Core  #
##########

# wait until mongo DB gets initialized
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

# populate core database
# add_ue_with_apn {imsi key opc apn}
# type {imsi type}: changes the PDN-Type of the first PDN: 1 = IPv4, 2 = IPv6, 3 = IPv4v6"
/open5gs/misc/db/open5gs-dbctl reset
for i in $(seq 1 $NUM_UES)
do	
	key_var="KEY${i}"
    opc_var="OPC${i}"
	key="${!key_var}"
    opc="${!opc_var}"
	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $MCC$MNC$PAD$i $key $opc $APN
	/open5gs/misc/db/open5gs-dbctl type $MCC$MNC$PAD$i $TYPE
done


sed -i "s/NETWORK_MCC/$MCC/g" amf.yaml
sed -i "s/NETWORK_MNC/$MNC/g" amf.yaml
sed -i "s/NETWORK_APN/$APN/g" amf.yaml
sed -i "s/NETWORK_MCC/$MCC/g" nrf.yaml
sed -i "s/NETWORK_MNC/$MNC/g" nrf.yaml
sed -i "s/NETWORK_APN/$APN/g" smf.yaml

/open5gs/install/bin/open5gs-nrfd -c /nrf.yaml &        # discover other core services
/open5gs/install/bin/open5gs-scpd &                     # enable indirect communication           
# /open5gs/install/bin/open5gs-seppd &                  # roaming security
/open5gs/install/bin/open5gs-amfd -c /amf.yaml &        # subscriber authentication
/open5gs/install/bin/open5gs-smfd -c /smf.yaml &        # session management
/open5gs/install/bin/open5gs-upfd -c /upf.yaml &        # transport data packets between gnb and external WAN
/open5gs/install/bin/open5gs-ausfd &                    # next three do sim authentication and hold user profile
/open5gs/install/bin/open5gs-udmd & 
/open5gs/install/bin/open5gs-udrd &
/open5gs/install/bin/open5gs-pcfd &                     # charging & enforcing subscriber policies
/open5gs/install/bin/open5gs-nssfd &                    # allow selecting network slice
/open5gs/install/bin/open5gs-bsfd &                     # binding support function

echo "Running 5G SA Core Network" > "./health.log"
wait -n