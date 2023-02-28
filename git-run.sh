#/bin/sh

docker run --rm -it -v ${PWD}:/git -v ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts zelejs/allin-web:git $@
