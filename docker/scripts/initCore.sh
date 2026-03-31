#!/bin/bash

echo "Starting Open5GS core services"

#############
# Time Zone #
#############

ln -sf /usr/share/zoneinfo/GMT /etc/localtime

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
/open5gs/misc/db/open5gs-dbctl reset
for i in $(seq 1 $NUM_UES)
do	
	key_var="KEY${i}"
    opc_var="OPC${i}"
	key="${!key_var}"
    opc="${!opc_var}"
	imsi=$(printf '%s%s%0*d' $MCC $MNC $((15 - ${#MCC} - ${#MNC})) $i)
	echo $imsi
	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $imsi $key $opc $APN
	/open5gs/misc/db/open5gs-dbctl type $imsi $TYPE
done

sed -i "s/LOG_TIME/$TIME/g" core.yaml
sed -i "s/NETWORK_MCC/$MCC/g" core.yaml
sed -i "s/NETWORK_MNC/$MNC/g" core.yaml

# Run Open5GS
/open5gs/build/tests/app/epc -c /core.yaml > core.log &

echo "Running LTE Network" > "./health.log"
wait -n