#!/bin/bash

PAD="000000000"
DB_URI="${DB_URI:-mongodb://localhost/open5gs}"

echo "Starting Open5GS core services"
echo "Running 5G SA Core Network" > "./health.log"

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
/open5gs/misc/db/open5gs-dbctl reset
# for i in $(seq 1 $NUM_UES)
# do	
# 	key_var="KEY${i}"
#     opc_var="OPC${i}"
# 	key="${!key_var}"
#     opc="${!opc_var}"
# 	imsi="$MCC$MNC$PAD$i"
# 	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $imsi $key $opc $APN
# 	/open5gs/misc/db/open5gs-dbctl type $imsi $TYPE
# 	# TODO: configure subscriber roaming type
# done

# roaming supports
tmpf="$(mktemp)"
awk '
	{ print }
	/# The following lines are desirable for IPv6 capable hosts/
	{ print \
	"127.0.1.10	nrf.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.1.11	ausf.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.1.12	udm.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.1.14	nssf.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.1.4	smf.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.1.15	bsf.5gc.mnc070.mcc999.3gppnetwork.org" ORS\
	"127.0.2.10	nrf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.11	ausf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.12	udm.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.14	nssf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.4	smf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.15	baf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.3.10	nrf.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"127.0.3.11	ausf.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"127.0.3.12	udm.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"127.0.3.14	nssf.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"127.0.3.4	smf.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"127.0.3.15	bsf.5gc.mnc010.mcc315.3gppnetwork.org" ORS\
	"# The following lines are desirable for IPv6 capable hosts" 
	}
	' /etc/hosts > $tmpf && cat $tmpf > /etc/hosts && rm -f $tmpf

/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp1-999-70.yaml &
/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp2-001-01.yaml &
/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp3-315-010.yaml &

/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-999-70-ue-001-01.yaml simple-test & 
# /open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-999-70-ue-315-010.yaml simple-test & 
# /open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-001-01-ue-999-70.yaml simple-test & 
# /open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-001-01-ue-315-010.yaml simple-test & 
# /open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-315-010-ue-999-70.yaml simple-test & 
# /open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-315-010-ue-001-01.yaml simple-test & 

echo "@@@@@@@@@@@@@@@@@@@@@@@@about to set the thing@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
imsi="001010000021309"
echo "db.subscribers.updateOne(
					{ 'imsi' : '$imsi'},
					{\$set: { 'slice.0.session.0.lbo_roaming_allowed' : $LBO }}
				);"
mongosh --eval "db.subscribers.updateMany(
					{},
					{ \$set: { 'slice.\$[].session.\$[].lbo_roaming_allowed': $LBO }}
				);" $DB_URI

wait -n