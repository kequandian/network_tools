#!/usr/bin/env bash
# dummy: continer; restart: restart container; deploy: deploy only
###############################
### start get working_dir
# if [ -f .env ];then source .env;fi
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


export DUMMY_DEPLOY_OPT=startup
export DUMMY_WORKING_DIR=$working_dir
docker-compose -f dummy.yml --project-name dummy-api up --always-recreate-deps -d
