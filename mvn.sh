#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
# echo working_dir= $working_dir
workingdir(){
   if [ ! $DUMMY_CONTAINER ];then
      if [ -f .env ];then source .env;fi
   fi
   curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):/webapps") | .captures[0].string'
}
working_dir=$(workingdir)
working_dir=${working_dir%\"}
working_dir=${working_dir#\"}
# echo working_dir= $working_dir
## end workding_dir


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


SRC=$working_dir
docker run --rm -v ~/.m2:/root/.m2 -v $SRC:/usr/src -w /usr/src --privileged $MAVEN_IMAGE mvn $@
