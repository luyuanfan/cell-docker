#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: .$0 config.json"
    exit 1
fi

ifconfig enp12s0f1np1 mtu 9000 # For 10 GigE
sysctl -w net.core.wmem_max=24862979

docker run -ti --privileged --network host --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/enb:x310-test ./initOperator.sh
# docker run -ti --privileged --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/enb:x310-test ./initOperator.sh
