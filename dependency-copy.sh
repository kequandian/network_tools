#!/usr/bin/env bash

## find pattern within fatjar
artifact_get_x(){
   ## get artifact from fatjar
   echo .
}

artifact_get() {
   local art=$1
   if [ ! $art ];then 
     exit
   fi
   if [[ $art =~ ':' ]];then 
      echo $art
   else
      local art_name=${art%%-[0-9\.]*.jar}
      local art_version=${art##*-};art_version=${art_version%.jar}
      echo $art_name:$art_version
   fi
}

## main 

artifact_pattern=$1
artifact=$(artifact_get $artifact_pattern)
outputdir=$2

if [ ! $outputdir ];then
  outputdir=data/lib
fi

if [ $outputdir ];then
  firstletter=${outputdir::1}  ##first letter
  if [ ! $firstletter = '/' ];then 
     outputdir="${PWD}/$outputdir"
  fi
  if [ ! -d $outputdir ];then
     mkdir $outputdir
  fi
  export DUMMY_WORKING_DIR="$outputdir"
fi

if [ ! $artifact ];then
   echo 'usage: dependency-copy <artifact:version> [.]'
   echo '    .  -- get dependency at local dir'
   exit
fi

./mvn.sh dependency:copy -Dartifact=com.jfeat:$artifact -DoutputDirectory=. 
