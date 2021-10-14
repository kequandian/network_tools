#!/usr/bin/env bash
###############################
if [ ! ${DUMMY_WORKING_DIR} ];then
  if [ -f .env ];then
    source .env
  fi
fi
###############################
MAVEN_IMAGE=$MAVEN_IMAGE_ARM32

# M2
###############################
MAVEN_M2_IMAGE=$MAVEN_M2_IMAGE_ARM32

if [ ! -d ~/.m2 ];then
  mkdir ~/.m2
fi
if [ ! -f ~/.m2/settings.xml ];then 
  docker run --rm -v ~/.m2:/var/m2 $MAVEN_M2_IMAGE cp /root/.m2/settings.xml /var/m2
fi
###############################


SRC=${DUMMY_WORKING_DIR}
if [ ! $SRC ];then 
   echo env DUMMY_WORKING_DIR not defined !
   echo pls. define DUMMY_WORKING_DIR env within .env
   exit
fi

# echo docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
