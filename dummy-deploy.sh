#!/usr/bin/env bash
# startup: start dummy api; restart: restart container; deploy: deploy only
if [ -f .env ];then source .env;fi
export DEPLOY_OPT=restart

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

########

docker-compose -f dummy.yml --project-name ${DUMMY_PROJECT_NAME}-deploy up --always-recreate-deps
