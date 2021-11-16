#!/usr/bin/env bash
#image='arm32v7/api:dummy'
#image='adoptopenjdk:11-jdk-hotspot'
image='zelejs/api:dummy'

args=$@

jar=$9
for arg in $args;do
  if [[ $arg = *.jar ]];then
    jar=$arg
  fi
done

if [[ ! $jar || ! -f $jar ]];then
   echo jar=$jar not exits!
   echo input args: $args
   exit
fi

basejar=${jar##*\/}
firstletter=${jar::1}  ##first letter
if [[ $firstletter = '/' ]];then
   basejar=/tmp/$basejar
   if [ -f $basejar ];then 
      unlink $basejar
   fi
   echo ln -s $jar $basejar
   ln -s $jar $basejar
fi

newargs=${args//$jar/$basejar}
# echo docker run --rm --privileged -v ${PWD}:/dummy -v $basejar:$basejar -w /dummy $image jar $newargs
docker run --rm --privileged -v ${PWD}:/dummy -v $basejar:$basejar -w /dummy $image jar $newargs

