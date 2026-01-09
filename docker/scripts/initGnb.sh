#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# gNB
sed -i "s/NETWORK_MCC/$MCC/g" gnb.yml
sed -i "s/NETWORK_MNC/$MNC/g" gnb.yml
sed -i "s/USRP_ID/$USRP/g" gnb.yml
exec chrt --rr 99 gnb -c gnb.yml cu_cp security --nea_pref_list=nea2,nea1,nea3,nea0