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
  binds=$(curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
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


# MAVEN_IMAGE
if [ -f .env ];then source .env;fi
###############################
machine=$(uname -m)
if [ $machine = armv7l ];then
MAVEN_IMAGE=$MAVEN_IMAGE_ARM32
else
MAVEN_IMAGE=$MAVEN_IMAGE_AMD64
fi
if [ ! $MAVEN_IMAGE ];then
  echo MAVEN_IMAGE not defined ! > /dev/stderr
  exit
fi
###############################

# M2
###############################
if [ ! -f ~/.m2/settings.xml ];then
  if [ $machine = armv7l ];then
    MAVEN_M2_IMAGE=$MAVEN_M2_IMAGE_ARM32
  else
    MAVEN_M2_IMAGE=$MAVEN_M2_IMAGE_AMD64
  fi
  if [ ! $MAVEN_M2_IMAGE ];then
    echo MAVEN_M2_IMAGE not defined ! > /dev/stderr
    exit
  fi 
  if [ ! -d ~/.m2 ];then
     mkdir ~/.m2
  fi
  docker run --rm -v ~/.m2:/var/m2 $MAVEN_M2_IMAGE cp /root/.m2/settings.xml /var/m2
fi
###############################

if [ ! ${DUMMY_WORKING_DIR} ];then
SRC=$working_dir
else 
SRC=${DUMMY_WORKING_DIR}
fi
docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
