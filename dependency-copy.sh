#!/usr/bin/env bash
artifact=$1
outputdir=$2

if [ $outputdir ];then
  if [ $outputdir = '.' ];then
  ## get artifact at current pwd,
  ## use DUMMY_WORKING_DIR for mvn.sh
     dest=$(pwd)
  else
     if [ ! -d $(pwd)/$outputdir ];then
        mkdir $(pwd)/$outputdir
     fi
     dest=$(pwd)
  fi

  export DUMMY_WORKING_DIR=$dest
fi

if [ ! $artifact ];then
   echo 'usage: dependency-copy <artifact:version> [.]'
   echo '    .  -- get dependency at local dir'
   exit
fi

./mvn.sh dependency:copy -Dartifact=com.jfeat:$artifact -DoutputDirectory=$outputdir 
