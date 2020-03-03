#!/bin/bash

WORKING_DIR="$1"
[ -z "$WORKING_DIR" ] && echo "Please specify local working directory" && exit 1
WORKING_DIR=$(realpath "$WORKING_DIR")

docker run -it --net=host --env="DISPLAY" \
  --volume="$HOME/.Xauthority:/root/.Xauthority" \
  --volume="$WORKING_DIR:/work:rw" \
  pebble-sdk bash