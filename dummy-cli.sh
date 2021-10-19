#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
   if [ ! $DUMMY_CONTAINER ];then
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
      echo $working_dir
    fi
  done
}
working_dir=$(workingdir)
################################

export DUMMY_WORKING_DIR=$working_dir
docker-compose -f dummy.yml run --rm dummy bash 
