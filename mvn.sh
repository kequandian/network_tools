#!/usr/bin/env bash
###############################
MAVEN_IMAGE_ARM32=arm32v7/maven:3.6-adoptopenjdk-11
MAVEN_IMAGE_AMD64=adoptopenjdk/maven-openjdk11
# maven:3.6-openjdk-11-slim
###############################
MAVEN_IMAGE=$MAVEN_IMAGE_ARM32


###############################
if [ -f .env ];then
   source .env
fi
###############################

if [ ! -d ~/.m2 ];then
  mkdir ~/.m2
fi
if [ ! -f ~/.m2/settings.xml ];then 
  docker run --rm -v ~/.m2:/var/m2 zelejs/allin-web:alpine-m2 cp /root/.m2/settings.xml /var/m2
fi

SRC=${DUMMY_WORKING_DIR}
if [ ! $SRC ];then 
   echo env DUMMY_WORKING_DIR not defined !
   echo pls. define DUMMY_WORKING_DIR env within .env
   exit
fi

# docker-compose -f mvn.yml run --rm maven bash
# 
docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src $MAVEN_IMAGE mvn $@
