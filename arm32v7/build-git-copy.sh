#!/bin/sh

docker image rm arm32v7/allin-web:git
docker image rm zelejs/allin-web:git

# docker-compose -f docker+buildimage+arm+copy.yml build --force-rm --no-cache
docker build . -t arm32v7/allin-web:git -f Dockerfile.git.copy

## clean up zelejs/allin-web:git
docker image rm zelejs/allin-web:git
