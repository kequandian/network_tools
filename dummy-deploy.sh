#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}

workingdir(){
   if [ ! ${DUMMY_CONTAINER} ];then
      if [ -f .env ];then source .env;fi
   fi
  #  curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):/webapps") | .captures[0].string'
  #  curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):([a-z/]*/webapps[a-z/]*)") | .captures[].string'
  binds=$(curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
  local working_dir
  for bind in $binds;do
    bind=${bind%\"}
    bind=${bind#\"}
    if [[ $bind == *webapps ]];then
      working_dir=${bind%:*}
      echo ${DUMMY_CONTAINER} $working_dir
    fi
  done
}
working_dir=$(workingdir)
################################
export DUMMY_DEPLOY_OPT=deploy
export DUMMY_WORKING_DIR=${working_dir##* }
export DUMMY_CONTAINER=${working_dir%% *}

## deploy with dependency:${version}
# dependency=$1
# if [ $dependency ];then 
#   ./dependency-copy.sh $dependency
# fi

# ## handle app deploy
# standalone=$(ls *-standalone *.war 2> /dev/null)
# if [ ! -z $standalone ];then
#   for app in $standalone;do
#     echo mv $app ${DUMMY_WORKING_DIR}
#     mv $app ${DUMMY_WORKING_DIR}
#   done   
# fi

#container=${DUMMY_CONTAINER}_dummy
#container_cmd=$(docker ps -a --format '{{.Names}}' | grep $container)
#if [[ $container_cmd && $container_cmd = $container ]];then
#   # has dummy container, just restart
#   docker-compose -f dummy.yml restart dummy
#else
  echo docker-compose -f dummy.yml up --always-recreate-deps
  docker-compose -f dummy.yml up --always-recreate-deps
#fi

