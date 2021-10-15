#!/usr/bin/env bash
# startup: start dummy api; restart: restart container; deploy: deploy only
if [ -f .env ];then source .env;fi
export DEPLOY_OPT=deploy

dependency=$1
if [ $dependency ];then 
  ./dependency-copy.sh $dependency
fi

docker-compose -f dummy.yml --project-name ${DUMMY_PROJECT_NAME}-deploy up --always-recreate-deps
