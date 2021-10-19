#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
   if [ ! $DUMMY_CONTAINER ];then
      if [ -f .env ];then source .env;fi
   fi
  #  curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):/webapps") | .captures[0].string'
  #  curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):([a-z/]*/webapps[a-z/]*)") | .captures[].string'
  binds=$(curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
  local working_dir
  for bind in $binds;do
    bind=${bind%\"}
    bind=${bind#\"}
    if [[ $bind == *webapps ]];then
      working_dir=${bind%:*}
      echo $working_dir
    fi
  done
}
################################
getfatjar(){
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/app.jar $working_dir/*.war 2> /dev/null)
  if [ -z $standalone ];then
     exit
  fi
  echo $standalone
}
################################

## main
JAR_BIN=$(which jar)

## find pattern within fatjar
artifact_get(){
   ## get artifact from fatjar
   pattern=$1
   if [ ! $pattern ];then
      echo . > /dev/null
      exit
   fi

   working_dir=$(workingdir)
   if [ -z "$working_dir" ];then 
      # echo no container: [${DUMMY_CONTAINER}] found ! > /dev/stderr
      echo $pattern
      exit
   fi
   fatjar=$(getfatjar)
   if [ -z "$fatjar" ];then 
      # echo + $working_dir
      # echo no fatjar found ! > /dev/stderr`
      echo $pattern
      exit
   fi

   # start
   result=$("$JAR_BIN" tf $fatjar | grep $pattern)
   num=0
   for entry in $result;do
      echo $entry > /dev/stderr
      num=$(($num+1))
   done

   if [ $num = 1 ];then 
      resultok=$("$JAR_BIN" xf $fatjar $result)
      echo $resultok
   elif [ $num = 0 ];then
      echo "no matches \"$pattern\" in $fatjar !" > /dev/stderr  
   fi
}

# convert jar-1.0.0.jar to com.jfeat:jar:1.0.0
artifact_x() {
   local art=$1
   local group_id='com.jfeat'
   if [ ! $art ];then 
     exit
   fi
   if [[ $art =~ ':' ]];then 
      echo $group_id:$art
   else
      local art_name=${art%%-[0-9\.]*.jar}
      local art_version=${art##*-};art_version=${art_version%.jar}
      echo $group_id:$art_name:$art_version
   fi
}


## main 

artifact_pattern=$1
artifact=$(artifact_get $artifact_pattern)
artifact=$(artifact_x $artifact)
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

./mvn.sh dependency:copy -Dartifact=$artifact -DoutputDirectory=. 
