#!/bin/bash

CONTAINER_NAME=$(docker ps -a | grep pebble-sdk | awk 'NF>1{print $NF}' | head -n 1)
[ -z "$CONTAINER_NAME" ] && { echo "No pebble-sdk container running"; exit; }

docker exec -it "$CONTAINER_NAME" bash