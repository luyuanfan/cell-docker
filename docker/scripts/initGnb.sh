#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# gNB
if [[ "$CONTAINER_NAME" == "gnb" ]]; then
    sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
    sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
    # sed -i "s/USRP_ID/$USRP1/g" gnb.yml
    exec chrt --rr 99 gnb -c gnb.yml
fi

## CU
if [[ "$CONTAINER_NAME" == "cu" ]]; then
    sed -i "s/NETWORK_MCC/$MCC/g" cu.yml
    sed -i "s/NETWORK_MNC/$MNC/g" cu.yml
    sed -i "s/USRP_ID/$USRP1/g" cu.yml
    cd /srsRAN_Project/build/apps/cu
    exec chrt --rr 99 srscu -c /cu.yml
fi
## DU B200
if [[ "$CONTAINER_NAME" == "du_1" ]]; then
    sed -i "s/NETWORK_MCC/$MCC/g" du_b200.yml
    sed -i "s/NETWORK_MNC/$MNC/g" du_b200.yml
    sed -i "s/USRP_ID/$USRP1/g" du_b200.yml
    cd /srsRAN_Project/build/apps/du
    exec chrt --rr 99 srsdu -c /du_b200.yml
fi 
## DU B205
if [[ "$CONTAINER_NAME" == "du_2" ]]; then
    sed -i "s/NETWORK_MCC/$MCC/g" du_b205.yml
    sed -i "s/NETWORK_MNC/$MNC/g" du_b205.yml
    sed -i "s/USRP_ID/$USRP2/g" du_b205.yml
    cd /srsRAN_Project/build/apps/du
    exec chrt --rr 99 srsdu -c /du_b205.yml
fi