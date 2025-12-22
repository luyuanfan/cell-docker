#!/bin/bash

PAD="000000000"

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

# sed -i "s/NETWORK_MCC/$MCC/g" amf.yaml
# sed -i "s/NETWORK_MNC/$MNC/g" amf.yaml
# sed -i "s/NETWORK_APN/$APN/g" amf.yaml
# sed -i "s/NETWORK_MCC/$MCC/g" nrf.yaml
# sed -i "s/NETWORK_MNC/$MNC/g" nrf.yaml
# sed -i "s/NETWORK_APN/$APN/g" smf.yaml

/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp1-999-70.yaml &
/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp2-001-01.yaml &
/open5gs/build/tests/app/5gc -c /open5gs/build/configs/examples/5gc-sepp3-315-010.yaml &

/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-999-70-ue-001-01.yaml simple-test
/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-999-70-ue-315-010.yaml simple-test
/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-001-01-ue-999-70.yaml simple-test
/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-001-01-ue-315-010.yaml simple-test
/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-315-010-ue-999-70.yaml simple-test
/open5gs/build/tests/registration/registration -c /open5gs/build/configs/examples/gnb-315-010-ue-001-01.yaml simple-test

# populate core database
/open5gs/misc/db/open5gs-dbctl reset
for i in $(seq 1 $NUM_UES)
do	
	key_var="KEY${i}"
    opc_var="OPC${i}"
	key="${!key_var}"
    opc="${!opc_var}"
	echo $MCC$MNC$PAD$i
	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $MCC$MNC$PAD$i $key $opc $APN
	/open5gs/misc/db/open5gs-dbctl type $MCC$MNC$PAD$i $TYPE
	# configure subscriber roaming type
done

# stale 
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

# # run home network
# /open5gs/install/bin/open5gs-nrfd -c /h-nrf.yaml
# /open5gs/install/bin/open5gs-scpd -c /h-scp.yaml
# /open5gs/install/bin/open5gs-ausfd -c /ausf.yaml
# /open5gs/install/bin/open5gs-udmd -c /udm.yaml
# /open5gs/install/bin/open5gs-udrd -c /udr.yaml
# /open5gs/install/bin/open5gs-smfd -c /h-smf.yaml
# /open5gs/install/bin/open5gs-upfd -c /h-upf.yaml
# /open5gs/install/bin/open5gs-pcfd -c /h-pcf.yaml
# /open5gs/install/bin/open5gs-bsfd -c /h-bsf.yaml
# /open5gs/install/bin/open5gs-nssfd -c /h-nssf.yaml
# /open5gs/install/bin/open5gs-seppd -c /sepp1.yaml

# # run visited network
# /open5gs/install/bin/open5gs-nrfd -c /nrf.yaml
# /open5gs/install/bin/open5gs-scpd -c /scp.yaml
# /open5gs/install/bin/open5gs-amfd -c /amf.yaml
# /open5gs/install/bin/open5gs-smfd -c /smf.yaml
# /open5gs/install/bin/open5gs-upfd -c /upf.yaml
# /open5gs/install/bin/open5gs-pcfd -c /pcf.yaml
# /open5gs/install/bin/open5gs-bsfd -c /bsf.yaml
# /open5gs/install/bin/open5gs-nssfd -c /nssf.yaml
# /open5gs/install/bin/open5gs-seppd -c /open5gs/install/etc/open5gs/sepp2.yaml


wait -n