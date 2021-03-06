#!/usr/bin/env bash

# for now, just use the IDA Pro container
if ! docker ps | grep idapro68 | grep Up >/dev/null; then
  # need to build the container
  echo "IDA Pro 6.8 container is not running!"
  exit 1
fi

container_id=$(docker ps | grep idapro68 | awk '{print $1}')

all_binds=$(docker inspect --format='{{.HostConfig.Binds}}' $container_id | sed 's|^\[||' | sed 's|\]$||')

my_array=()
for arg in "$@"; do
  arg=$(echo "$arg" | sed "s|~/|$HOME/|g")

  for i in $all_binds; do
    outside=$(echo $i | cut -d: -f1)
    inside=$(echo $i | cut -d: -f2)

    arg=$(echo "$arg" | sed "s|$outside|$inside|g")
  done
  my_array+=("$arg")
done

set -x
docker exec $container_id python3 /af-metingen/measure/compare.py "${my_array[@]}"