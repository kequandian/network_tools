#!/usr/bin/env bash
#!/usr/bin/env bash
# if [ -f .env ];then source .env;fi 
# cd ${DUMMY_COMPOSE_DIR}
composedir(){
   if [ ! $DUMMY_CONTAINER ];then
     if [ -f .env ];then source .env;fi
   fi
   if [ ! $DUMMY_HOST ];then
     DUMMY_HOST=localhost
   fi
   if [ ! $DUMMY_PORT ];then
     DUMMY_PORT='2375'
   fi
   curl -s http://$DUMMY_HOST:$DUMMY_PORT/containers/${DUMMY_CONTAINER}/json | jq '.Config.Labels."com.docker.compose.project.working_dir"'
}
##################################
compose_dir=$(composedir)
compose_dir=${compose_dir%\"}
compose_dir=${compose_dir#\"}
## end compose dir

cd ${compose_dir}
echo ${PWD}

# echo JAVA_OPTS='-agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n' docker-compose up -d
JAVA_OPTS='' docker-compose up -d

