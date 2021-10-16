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

# echo docker run --rm -it -v ${PWD}:/git -v ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts arm32v7/allin-web:git $@
docker run --rm -it --net=host -v ${PWD}:/git -v ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts arm32v7/allin-web:git $@
