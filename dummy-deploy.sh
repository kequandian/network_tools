#!/usr/bin/env bash
###############################
### start get working_dir
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
   if [ ! $DUMMY_CONTAINER ];then
      if [ -f .env ];then source .env;fi
   fi
   curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):/webapps") | .captures[0].string'
}
working_dir=$(workingdir)
working_dir=${working_dir%\"}
working_dir=${working_dir#\"}
## end workding_dir
################################


export DUMMY_DEPLOY_OPT=restart
export DUMMY_WORKING_DIR=$working_dir

## deploy with dependency:${version}
dependency=$1
if [ $dependency ];then 
  ./dependency-copy.sh $dependency
fi

## handle app deploy
standalone=$(ls *-standalone *.war 2> /dev/null)
if [ ! -z $standalone ];then
  for app in $standalone;do
    echo mv $app ${DUMMY_WORKING_DIR}
    mv $app ${DUMMY_WORKING_DIR}
  done   
fi

# export DUMMY_DEPLOY_OPT=restart
# export DUMMY_WORKING_DIR=$working_dir
docker-compose -f dummy.yml --project-name "dummy-${DUMMY_TARGET_CONTAINER}-deploy" up --always-recreate-deps
