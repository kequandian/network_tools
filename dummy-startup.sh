#!/usr/bin/env bash
# dummy: continer; restart: restart container; deploy: deploy only
if [ -f .env ];then source .env;fi
export DEPLOY_OPT=startup
export DUMMY_PROJECT_NAME=dummy-api
docker-compose -f dummy.yml --project-name $DUMMY_PROJECT_NAME up --always-recreate-deps -d
