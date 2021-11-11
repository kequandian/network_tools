#/bin/sh
#image='arm32v7/api:dummy'
image='adoptopenjdk:11-jdk-hotspot'

docker run --rm --privileged -v ${PWD}:/dummy -w /dummy $image jar $@

