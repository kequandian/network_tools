#!/usr/bin/env bash
###############################
if [ ! ${DUMMY_WORKING_DIR} ];then
  if [ -f .env ];then
    source .env
  fi
fi
SRC=${DUMMY_WORKING_DIR}
if [ ! $SRC ];then
   echo env DUMMY_WORKING_DIR not defined ! > /dev/stderr
   exit
fi

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


# echo docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
# echo WORKING_DIR=$SRC
docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
