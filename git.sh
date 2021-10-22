#!/bin/sh
### git.yaml
##############################
# version: "3"
# services:
#   git:
#     image: zelejs/allin-web:git
#     volumes:
#       - ${PWD}/:/git
#       - ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts
##############################

# docker run --rm -it --net=host -v ${PWD}:/git -v ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts arm32v7/allin-web:git $@
readpath(){
   local path
   osname=$(uname)
   if [ $osname = Darwin ];then  ## MAC
      path=$(greadlink -f "$0")
   else                                ## Windows
      path=$(readlink -f "$0")
   fi
   echo $(dirname $path)
}

docker-compose -f $(readpath)/local/yaml/git.yaml run --rm git $@
