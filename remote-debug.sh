#!/usr/bin/env bash
# if [ -f .env ];then source .env;fi 
# cd ${DUMMY_COMPOSE_DIR}
composedir(){
   curl -s http://localhost:2375/containers/biliya-api/json | jq '.Config.Labels."com.docker.compose.project.working_dir"'
}
compose_dir=$(composedir)
compose_dir=${compose_dir%\"}
compose_dir=${compose_dir#\"}
## end compose dir

cd ${compose_dir}
echo ${PWD}

echo JAVA_OPTS='-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n' docker-compose up -d
JAVA_OPTS='-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n' docker-compose up -d

