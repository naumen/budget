#!/bin/bash

set -eux
printenv

for CONFIG_FILE in database_docker secrets settings
do
  if [ ! -f "config/${CONFIG_FILE}.yml" ]; then
    cp config/${CONFIG_FILE}.yml.template config/${CONFIG_FILE}.yml
  fi
done

mkdir -p /var/www/budget/tmp/pids
mkdir -p /var/www/budget/tmp/cache
mkdir -p /var/www/budget/tmp/sockets
