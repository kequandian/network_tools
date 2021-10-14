#!/usr/bin/env bash
outputdir=lib

artifact=$1
dest=$2
if [ $dest -a $dest = '.' ];then
  ## get artifact at current pwd,
  ## use DUMMY_WORKING_DIR for mvn.sh
  currentdir=$(pwd)
  DUMMY_WORKING_DIR=$currentdir
fi

if [ ! $artifact ];then
   echo 'usage: dependency-copy <artifact:version>'
   exit
fi

./mvn.sh dependency:copy -Dartifact=com.jfeat:$artifact -DoutputDirectory=$outputdir 
