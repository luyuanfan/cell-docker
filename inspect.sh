#!/bin/bash
if [ "$1" = "-c" ]; then
    CONTAINER_NAME="core"
else
    CONTAINER_NAME="gnb"
fi

CONTAINER_ID=$(docker ps -qf name=$CONTAINER_NAME)

docker exec -it "$CONTAINER_ID" bash