#!/bin/bash

echo "Running 5G SA VPLMN Network" > "./health.log"

mkdir -p /logs
# exec > >(tee -a /logs/$TIME-vplmn.log)
# exec 2>&1

echo "Starting Open5GS VPLMN services"

#############
# Time Zone #
#############

ln -sf /usr/share/zoneinfo/GMT /etc/localtime

## NOTE: VPLMN does not use their DB for roaming

# roaming supports
tmpf="$(mktemp)"
awk '
	{ print }
	/# The following lines are desirable for IPv6 capable hosts/
	{ print \
	"127.0.2.10	nrf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.11	ausf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.12	udm.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.14	nssf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.4	smf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"127.0.2.15	bsf.5gc.mnc001.mcc001.3gppnetwork.org" ORS\
	"# The following lines are desirable for IPv6 capable hosts" 
	}
	' /etc/hosts > $tmpf && cat $tmpf > /etc/hosts && rm -f $tmpf

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

tail -qF /nrf.log /scp.log /amf.log /smf.log \
		/upf.log /pcf.log /bsf.log /nssf.log \
		/sepp2.log >> /logs/$TIME-vplmn.log &

wait -n