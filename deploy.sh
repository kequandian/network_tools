#!/bin/sh
# dummy: continer; restart: restart container; deploy: deploy only
export DEPLOY_OPT=deploy
docker-compose -f dummy.yml up --always-recreate-deps 
