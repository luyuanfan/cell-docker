#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: .$0 config.json"
    exit 1
fi

# ./docker/scripts/srsran_performance # Contains sysctl commands, cannot do in containers
ifconfig enp12s0f1np1 mtu 9000 # For 10 GigE

docker run -ti --privileged --network host --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/gnb:x310 ./initOperator.sh
# docker run -ti --privileged --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/gnb:x310 ./initOperator.sh
