#!/bin/sh

docker image rm arm32v7/allin-web:alpine-m2
docker image rm zelejs/allin-web:alpine-m2

# docker-compose -f docker+buildimage+arm+copy.yml build --force-rm --no-cache
docker build . -t arm32v7/allin-web:alpine-m2 -f Dockerfile.m2.copy

## clean up zelejs/allin-web:alpine-m2
docker image rm zelejs/allin-web:alpine-m2