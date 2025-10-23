#!/bin/bash
CONTAINER_NAME="luyuanfan/gnb"
CONTAINER_ID=$(docker ps | grep -e "$CONTAINER_NAME" | awk '{print $1}')

docker exec -it "$CONTAINER_ID" bash