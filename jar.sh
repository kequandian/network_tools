#!/bin/sh

currentdir=$(pwd)
SRC=$currentdir

# docker-compose -f mvn.yml run --rm maven bash
docker run --rm -v $SRC:/usr/src -w /usr/src maven:3.6-openjdk-11-slim jar $@
