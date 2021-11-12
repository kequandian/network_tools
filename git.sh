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
docker-compose -f $dir/local/yaml/git.yaml run --rm git $@
