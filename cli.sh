#!/usr/bin/env bash
###############################
###############################
### start get working_dir
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
