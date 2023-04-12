#!/bin/sh
usage(){
   echo "usage: dependency-copy.sh <groupId:artifact:version[:jar:classifier]> [output]"
   exit
}
if [ ! $@ ];then
   usage
fi
ARTIFACT=$1
outputdir=$2

#dir=$(dirname $0)
#cd $dir
docker run --rm -v ${PWD}/$outputdir:/usr/src/lib zelejs/allin-web:dependency-copy $ARTIFACT
