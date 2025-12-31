#!/bin/bash

cat >/etc/ld.so.conf.d/open5gs.conf <<'EOF'
/open5gs/install/lib
/open5gs/install/lib/x86_64-linux-gnu
EOF
ldconfig

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
	"127.0.2.15	bsf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
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

# populate core database
/open5gs/misc/db/open5gs-dbctl reset
for i in $(seq 1 $NUM_UES)
do	
	key_var="KEY${i}"
    opc_var="OPC${i}"
	key="${!key_var}"
    opc="${!opc_var}"
	imsi=$(printf '%s%s%0*d' $HMCC $HMNC $((15 - ${#HMCC} - ${#HMNC})) $i)
	/open5gs/misc/db/open5gs-dbctl add_ue_with_apn $imsi $key $opc $APN
	/open5gs/misc/db/open5gs-dbctl type $imsi $TYPE
done

# run home network
/open5gs/install/bin/open5gs-nrfd -c /h-nrf.yaml &
/open5gs/install/bin/open5gs-scpd -c /h-scp.yaml & 
/open5gs/install/bin/open5gs-ausfd -c /ausf.yaml &
/open5gs/install/bin/open5gs-udmd -c /udm.yaml &
/open5gs/install/bin/open5gs-udrd -c /udr.yaml &
/open5gs/install/bin/open5gs-smfd -c /h-smf.yaml &
/open5gs/install/bin/open5gs-upfd -c /h-upf.yaml &
/open5gs/install/bin/open5gs-pcfd -c /h-pcf.yaml &
/open5gs/install/bin/open5gs-bsfd -c /h-bsf.yaml &
/open5gs/install/bin/open5gs-nssfd -c /h-nssf.yaml &
/open5gs/install/bin/open5gs-seppd -c /sepp1.yaml &

# run visited network
/open5gs/install/bin/open5gs-nrfd -c /nrf.yaml &
/open5gs/install/bin/open5gs-scpd -c /scp.yaml &
/open5gs/install/bin/open5gs-amfd -c /amf.yaml &
/open5gs/install/bin/open5gs-smfd -c /smf.yaml &
/open5gs/install/bin/open5gs-upfd -c /upf.yaml &
/open5gs/install/bin/open5gs-pcfd -c /pcf.yaml &
/open5gs/install/bin/open5gs-bsfd -c /bsf.yaml &
/open5gs/install/bin/open5gs-nssfd -c /nssf.yaml &
/open5gs/install/bin/open5gs-seppd -c /sepp2.yaml &

echo "Running 5G SA Core Network" > "./health.log"
wait -n
