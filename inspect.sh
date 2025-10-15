#!/bin/bash
CONTAINER_NAME="luyuanfan/enb"
CONTAINER_ID=$(docker ps | grep "$CONTAINER_NAME" | awk '{print $1}')

docker exec -it "$CONTAINER_ID" bash
