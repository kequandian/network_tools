#!/bin/sh

SSH_PATH=$(readlink -f $0)
GIT_SSH_ROOT=${SSH_PATH%\/*}/git-ssh

#docker run --rm -e GIT_SSH_COMMAND="ssh -i /git-ssh/id_rsa -o IdentitiesOnly=yes" \
#       -v ${PWD}:/git \
#       -v ${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts \
#       -v $GIT_SSH_ROOT:/git-ssh \
#       zelejs/allin-web:git $@

GIT_SSH_COMMAND="ssh -i $GIT_SSH_ROOT/id_rsa -o IdentitiesOnly=yes" git $@
