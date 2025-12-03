#!/bin/bash
CONTAINER_NAME="jasminetest2"
CONTAINER_ID=$(docker ps | grep -e "$CONTAINER_NAME" | awk '{print $1}')

docker exec -it "$CONTAINER_ID" bash