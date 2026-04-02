#!/bin/bash

#############
# Time Zone #
#############

ln -sf /usr/share/zoneinfo/GMT /etc/localtime

# gNB
sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
sed -i "s/USRP_ID/$USRP/g" gnb.yml
sed -i "s/LOG_TIME/$TIME/g" gnb.yml
exec chrt --rr 99 gnb -c gnb.yml