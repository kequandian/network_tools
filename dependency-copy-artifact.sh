#!/bin/sh
usage(){
   echo "usage: dependency-copy.sh <groupId:artifact:version[:jar:classifier]>"
   exit
}
if [ ! $@ ];then
   usage
fi
ARTIFACT=$1

#dir=$(dirname $0)
#cd $dir
docker run --rm -v ${PWD}:/usr/src/lib zelejs/allin-web:dependency-copy $ARTIFACT
