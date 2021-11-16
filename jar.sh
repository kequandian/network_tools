#!/usr/bin/env bash
#image='arm32v7/api:dummy'
image='adoptopenjdk:11-jdk-hotspot'

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

basejar=$(basename $jar)
firstletter=${jar::1}  ##first letter
if [[ $firstletter = '/' ]];then 
   ln -s $jar $basejar
fi

newargs=${args//$jar/$basejar}
docker run --rm --privileged -v ${PWD}:/dummy -w /dummy $image jar $newargs

