#!/bin/sh
docker run -it --name dummy-commit arm32v7/api:dummy bash

docker commit dummy-commit
docker images

echo 
echo 'docker tag <> arm32v7/api:dummy'
echo 'docker container rm dummy-commit'

