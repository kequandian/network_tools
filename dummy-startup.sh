#!/usr/bin/env bash
# dummy: continer; restart: restart container; deploy: deploy only
###############################
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
  if [ ! $DUMMY_CONTAINER ];then
    if [ -f .env ];then source .env;fi
  fi
  if [ ! $DUMMY_HOST ];then
    DUMMY_HOST=localhost
  fi
  if [ ! $DUMMY_PORT ];then
    DUMMY_PORT='2375'
  fi

  echo curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/containers/${DUMMY_CONTAINER}/json > /dev/stderr
  binds=$(curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')

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
export DUMMY_DEPLOY_OPT=startup
export DUMMY_WORKING_DIR=${working_dir##* }
export DUMMY_CONTAINER=${working_dir%% *}

container=${DUMMY_CONTAINER}_dummy
container_cmd=$(docker ps -a --format '{{.Names}}' | grep $container)
if [[ $container_cmd && $container_cmd = $container ]];then
   # has dummy container, just rm it
   docker stop $container
   docker rm $container
fi

docker-compose -f dummy.yml up --always-recreate-deps -d

