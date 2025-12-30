#!/bin/bash
CONTAINER_NAME="core"
CONTAINER_ID=$(docker ps -qf name=$CONTAINER_NAME)

docker exec -it "$CONTAINER_ID" bash