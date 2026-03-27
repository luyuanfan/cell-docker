#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# eNB
sed -i "s/NETWORK_MCC/$MCC/g" enb.conf
sed -i "s/NETWORK_MNC/$MNC/g" enb.conf
sed -i "s/USRP_ID/$USRP/g" enb.conf
sed -i "s/LOG_TIME/$TIME/g" enb.conf
sed -i "s/NUM_PRBS/$NUM_PRBS/g" enb.conf
sed -i "s/TRANSMISSION_MODE/$TRANSMISSION_MODE/g" enb.conf
sed -i "s/NUM_PORTS/$NUM_PORTS/g" enb.conf
sed -i "s/#DL_EARFCN/dl_earfcn = $DL_EARFCN/g" enb.conf

srsenb enb.conf