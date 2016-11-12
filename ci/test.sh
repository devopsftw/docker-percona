#!/bin/sh
set -e
set -x

CONSUL_CONT=$(docker run -d -p 8500:8500 devopsftw/consul agent -dev -datacenter circle)
CONSUL_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $CONSUL_CONT)
CONT_56=$(docker run -d -e "CONSUL_JOIN=$CONSUL_IP" -e "CONSUL_DC=circle" -e "CONSUL_SERVICE_NAME=prc56" -e "MYSQL_ROOT_PASSWORD=test" devopsftw/percona:5.6)
CONT_57=$(docker run -d -e "CONSUL_JOIN=$CONSUL_IP" -e "CONSUL_DC=circle" -e "CONSUL_SERVICE_NAME=prc57" -e "MYSQL_ROOT_PASSWORD=test" devopsftw/percona:5.7)

CONT_56_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $CONT_56)
CONT_57_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $CONT_57)

sleep 25

nc -z -v $CONT_56_IP 3306
test $(curl -s 'localhost:8500/v1/health/service/prc56' | jq -c '.[0].Node') != 'null'

nc -z -v $CONT_57_IP 3306
test $(curl -s 'localhost:8500/v1/health/service/prc57' | jq -c '.[0].Node') != 'null'
