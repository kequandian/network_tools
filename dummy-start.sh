#!/usr/bin/env bash
# dummy opt => deploy: only without restart; restart: restart container required;  dummy: start dummy api
###############################
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
  if [[ ! $DUMMY_CONTAINER || ! $DUMMY_HOST ]];then
    if [ -f .env ];then source .env;fi
  fi
  if [ ! $DUMMY_HOST ];then
     DUMMY_HOST=localhost
  fi
  if [ ! $DUMMY_PORT ];then
     DUMMY_PORT='2375'
  fi

  binds=$(curl -s http://$DUMMY_HOST:$DUMMY_PORT/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
  local working_dir
  for bind in $binds;do
    bind=${bind%\"}
    bind=${bind#\"}
    if [[ $bind == *webapps ]];then
      working_dir=${bind%:*}
      echo $DUMMY_CONTAINER $working_dir
    fi
  done
}
working_dir=$(workingdir)
################################
export DUMMY_DEPLOY_OPT=deploy
export DUMMY_WORKING_DIR=${working_dir##* }
export DUMMY_CONTAINER=${working_dir%% *}
echo DUMMY_CONTAINER=$DUMMY_CONTAINER

if [ ! $DUMMY_CONTAINER ];then 
   echo "failure: DUMMY_CONTAINER not present !"
   exit
fi

container=${DUMMY_CONTAINER}_dummy
container_cmd=$(docker ps -a --format '{{.Names}}' | grep $container)
if [[ $container_cmd && $container_cmd = $container ]];then
   # has dummy container, already start, do nothing
   echo $container already started ...
   exit
fi

#  docker-compose -f dummy.yml up --always-recreate-deps
docker-compose -f dummy.yml up
