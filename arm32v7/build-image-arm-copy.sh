#!/bin/sh

docker image rm arm32v7/api:dummy
docker image rm zelejs/api:dummy

docker-compose -f docker+buildimage+arm+copy.yml build --force-rm --no-cache

## clean up after build
docker image rm zelejs/api:dummy