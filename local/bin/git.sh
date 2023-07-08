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
dir=$(dirname $(realpath "$0"))

yaml='git.yaml'
arch=$(uname -m)
if [ "$arch"x = "armv7l"x ];then
   yaml='git.arm32v7.yaml'
fi

docker-compose -f $dir/local/yaml/$yaml run --rm git $@
