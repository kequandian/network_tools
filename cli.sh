#!/usr/bin/env bash
###############################
if [ -f .env ];then source .env;fi
SRC=${DUMMY_WORKING_DIR}
if [ ! $SRC ];then 
   echo env DUMMY_WORKING_DIR not defined !
   echo pls. define DUMMY_WORKING_DIR env within .env
   exit
fi

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
  echo 'usage: cli.sh <command line>'
  exit
fi

LOCAL_ROOT=$(pwd)/local

# docker-compose -f mvn.yml run --rm maven bash
# echo docker run --rm -it -v $SRC:/webapps -v $LOCAL_ROOT:/webapps/local -w /webapps --privileged $MAVEN_IMAGE $@
docker run --rm -it -v $SRC:/webapps -v $LOCAL_ROOT:/webapps/local -w /webapps --privileged $MAVEN_IMAGE $@
