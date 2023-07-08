#/bin/sh
docker run --rm -it -v $PWD/git-ssh:/ssh --entrypoint sh zelejs/allin-web:git -c "cp /root/.ssh/* /ssh"
