#!/bin/bash
if [ "$1" = "-h" ]; then
    CONTAINER_NAME="hplmn"
elif [ "$1" = "-v" ]; then
    CONTAINER_NAME="vplmn"
else
    CONTAINER_NAME="gnb"
fi

CONTAINER_ID=$(docker ps -qf name=$CONTAINER_NAME)

docker attach "$CONTAINER_ID"