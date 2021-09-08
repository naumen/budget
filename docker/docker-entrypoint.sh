#!/bin/bash

set -eux
printenv

if [ ! -f "config/database.yml" ]; then
  cp config/database_docker.yml.template config/database.yml
fi

for CONFIG_FILE in secrets settings
do
  if [ ! -f "config/${CONFIG_FILE}.yml" ]; then
    cp config/${CONFIG_FILE}.yml.template config/${CONFIG_FILE}.yml
  fi
done

mkdir -p /var/www/budget/tmp/pids
mkdir -p /var/www/budget/tmp/cache
mkdir -p /var/www/budget/tmp/sockets

case $1 in
    budget)
        bundle exec thin start
        ;;
    *)
        exec "$@"
        ;;
esac
