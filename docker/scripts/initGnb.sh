#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# gNB
sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
sed -i "s/USRP_ID/$USRP1/g" gnb.yml

# sleep 100000
exec chrt --rr 99 ./srsRAN_Project/build/apps/gnb/gnb -c gnb.yml