#!/bin/sh
docker run --rm -v $HOME/.m2:/root/.m2 -v $PWD:/usr/src -w /usr/src maven:3.6-adoptopenjdk-11 mvn -DskipStandalone=false clean package
