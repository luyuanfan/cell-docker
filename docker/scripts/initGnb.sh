#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

## CU

sed -i "s/NETWORK_MCC/$MCC/g" cu.yml
sed -i "s/NETWORK_MNC/$MNC/g" cu.yml
sed -i "s/USRP_ID/$USRP1/g" cu.yml

## DU B200

sed -i "s/NETWORK_MCC/$MCC/g" du_b200.yml
sed -i "s/NETWORK_MNC/$MNC/g" du_b200.yml
sed -i "s/USRP_ID/$USRP1/g" du_b200.yml

## DU B205
sed -i "s/NETWORK_MCC/$MCC/g" du_b205.yml
sed -i "s/NETWORK_MNC/$MNC/g" du_b205.yml
sed -i "s/USRP_ID/$USRP2/g" du_b205.yml

wait
# (
# 	cd /srsRAN_Project/build/apps/cu && chrt --rr 99 srscu -c /cu.yml &
# 	cd /srsRAN_Project/build/apps/du && chrt --rr 99 srsdu -c /du_b200.yml &
# 	cd /srsRAN_Project/build/apps/du && chrt --rr 99 srsdu -c /du_b205.yml &
# ) 2>&1 | tee /gnb.log