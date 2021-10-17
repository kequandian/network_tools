#!/usr/bin/env bash
if [ -f .env ];then source .env;fi 

cd ${DUMMY_COMPOSE_DIR}
echo ${PWD}

echo JAVA_OPTS='-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n' docker-compose up -d
JAVA_OPTS='-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n' docker-compose up -d

