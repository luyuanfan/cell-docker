#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "USE: $0 <Operator Config File (JSON)>"
	echo "Example: .$0 config.json"
    exit 1
fi

docker run -ti --privileged -v /tmp/gnb/:/tmp/ --network host --cap-add=SYS_NICE --ulimit rtprio=99 --ulimit rttime=-1 --ulimit memlock=8428281856 -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/gnb:x310 ./initOperator.sh
# docker run -ti --privileged --rm -v /dev/:/dev/ -e CONFIG64="$(base64 $1)" luyuanfan/gnb:x310 ./initOperator.sh
