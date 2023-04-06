#!/usr/bin/env bash
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
      echo $working_dir
    fi
  done
}
working_dir=$(workingdir)
################################


#################################
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

if [ ! $@ ];then
  echo 'usage: cli.sh <entrypoint>'
  exit
fi

SRC=$working_dir
LOCAL_ROOT=$(pwd)/local
# docker-compose -f mvn.yml run --rm maven bash
# echo docker run --rm -it -v $SRC:/webapps -v $LOCAL_ROOT:/webapps/local -w /webapps --privileged $MAVEN_IMAGE $@
docker run --rm -it -v $SRC:/webapps -v $LOCAL_ROOT:/webapps/local -w /webapps --privileged $MAVEN_IMAGE $@
