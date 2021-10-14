#!/usr/bin/env bash
###############################
if [ ! ${DUMMY_WORKING_DIR} ];then
  if [ -f .env ];then
    source .env
  fi
fi
###############################
MAVEN_IMAGE=$MAVEN_IMAGE_ARM32


SRC=${DUMMY_WORKING_DIR}
if [ ! $SRC ];then 
   echo env DUMMY_WORKING_DIR not defined !
   echo pls. define DUMMY_WORKING_DIR env within .env
   exit
fi

# docker-compose -f mvn.yml run --rm maven bash
docker run --rm -v $SRC:/webapps -w /webapps --privileged $MAVEN_IMAGE jar $@
