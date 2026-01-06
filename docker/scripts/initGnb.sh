#!/bin/bash

#############
# Time Zone #
#############

echo "Etc/Universal" > /etc/timezone

# gNB
exec chrt --rr 99 gnb -c gnb.yml