#!/usr/bin/env bash
if [ -f .env ];then source .env;fi
artifact_get() {
   local art=$1
   if [[ $art =~ ':' ]];then 
      echo $art
   else
      local art_name=${art%%-[0-9\.]*.jar}
      local art_version=${art##*-};art_version=${art_version%.jar}
      echo $art_name:$art_version
   fi
}
artifact_input=$1
artifact=$(artifact_get $artifact_input)
outputdir=$2


if [ ! $outputdir ];then
  outputdir=data/lib
fi

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
