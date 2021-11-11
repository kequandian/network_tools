#!/usr/bin/env bash
###############################
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


###############################
if [ -f .env ];then source .env;fi
machine=$(uname -m)
if [ $machine = armv7l ];then
MAVEN_IMAGE=$MAVEN_IMAGE_ARM32
else
MAVEN_IMAGE=$MAVEN_IMAGE_AMD6G
fi
if [ ! $MAVEN_IMAGE ];then
  echo MAVEN_IMAGE not defined ! > /dev/stderr
  exit
fi 
###############################

SRC=$working_dir
# docker-compose -f mvn.yml run --rm maven bash
docker run --rm -v $SRC:/webapps -w /webapps --privileged $MAVEN_IMAGE jar $@
