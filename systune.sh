
#############
#  MongoDB  #
#############
# If mongo is not running, execute it in the background
nc -zvv localhost 27017 > /dev/null 2>&1
if [ $? -ne 0 ]; then
	mongod --fork --logpath /mongod.log
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

# # Populate core database
# for i in $(seq -f "%010g" 1 $NUM_UES)
# do
# 	/open5gs/misc/db/open5gs-dbctl add $MCC$MNC$i $KEY $OPC
# done

# # Get main interface IP
# # Modify the Core configuration file 
# sed -i "s/NETWORK_MCC/$MCC/g" config.yaml
# sed -i "s/NETWORK_MNC/$MNC/g" config.yaml


# Run Open5GS
/open5gs/build/tests/app/epc -c /config.yaml > core.log &
echo "Running 4G Core Network"
sleep 1


# #########
# #  RAN  #
# #########
# sed -i "s/NETWORK_MCC/$MCC/g" enb.conf
# sed -i "s/NETWORK_MNC/$MNC/g" enb.conf
# sed -i "s/USRP_ID/$USRP/g" enb.conf
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