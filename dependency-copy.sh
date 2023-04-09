#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
workingdir(){
  if [ ! $DUMMY_CONTAINER ];then
    if [ -f .env ];then source .env;fi
  fi
  if [ ! $DUMMY_HOST ];then
    DUMMY_HOST=localhost
  fi
  if [ ! $DUMMY_PORT ];then
    DUMMY_PORT='2375'
  fi

  echo curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/containers/${DUMMY_CONTAINER}/json > /dev/stderr
  binds=$(curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')

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
  if [ -z "$standalone" ];then
     exit
  fi
  echo $standalone
}
################################

## main
dir=$(dirname $(realpath $0))
if [ ! $dir ];then
  dir='.';
fi
JAR_BIN=$(which jar)
if [ ! $JAR_BIN ];then
   JAR_BIN="$dir/jar.sh"
fi

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
      echo $pattern
      exit
   fi
   fatjar=$(getfatjar)
   if [ -z "$fatjar" ];then 
      echo $pattern
      exit
   fi

   # start
   result=$("$JAR_BIN" tf $fatjar | grep $pattern)
   num=0
   for entry in $result;do
      num=$(($num+1))
   done

   if [ $num = 1 ];then 
      echo ${result##*\/}
   elif [ $num = 0 ];then
      echo "no matches \"$pattern\" in $fatjar !" > /dev/stderr  
   else
     for entry in $result;do
       echo $entry > /dev/stderr
     done
     echo '.'  ## means multi matches
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
      #echo $group_id:$art
      echo $art
   else
      local art_name=${art%%-[0-9\.]*.jar}
      local art_version=${art##*-};art_version=${art_version%.jar}
      echo $group_id:$art_name:$art_version
   fi
}


## main 
usage(){
  echo 'usage: dependency-copy <group:artifact:version> [output-dir]'
  echo '   output-dir:  default .'
  exit -1
}
if [ ! $1 ];then
  usage
fi

artifact_pattern=$1
artifact_ok=$(artifact_get $artifact_pattern)
if [ ! $artifact_ok -o $artifact_ok = '.' ];then 
   # exit after show matches
   exit
fi
artifact=$(artifact_x $artifact_ok)
outputdir=$2

if [ ! $artifact ];then
  usage
fi

if [ ! $outputdir ];then
  outputdir=.
fi

if [ $outputdir ];then
  firstletter=${outputdir::1}  ##first letter
  if [ ! $firstletter = '/' ];then 
     outputdir="${PWD}/$outputdir"
  fi
  if [ ! -d $outputdir ];then
     mkdir -p $outputdir
  fi
  export DUMMY_WORKING_DIR="$outputdir"  ## DUMMY_WORKING_DIR for ./mvn.sh
fi

clean_repo_artifact(){
   local art=$1
   local m2_home
   if [ ${M2_HOME} -a -d ${M2_HOME} ];then 
      m2_home=${M2_HOME}
   elif [ ${MAVEN_HOME} -a -d ${MAVEN_HOME} ];then 
      m2_home=${MAVEN_HOME}
   else
      m2_home=${HOME}/.m2
   fi

   local groupid=${art%%:*}
         groupid=${groupid//./\/}  ## replace . with /
   local version=${art##*:}
   local name=${art%:*}
         name=${name#*:}

   if [ -d $m2_home/repository/$groupid/$name/$version ];then
      tree $m2_home/repository/$groupid/$name/$version
      echo rm -rf $m2_home/repository/$groupid/$name/$version
      sudo rm -rf $m2_home/repository/$groupid/$name/$version
   fi
}

echo + $artifact
# echo mvn dependency:copy -Dartifact=$artifact -DoutputDirectory=$DUMMY_WORKING_DIR
clean_repo_artifact $artifact
mvn_ok=$(which mvn 2> /dev/null)
if [ -z $mvn_ok ];then 
   echo mvn has not yet installed !
   echo apt install -y mvn
   exit
fi
mvn dependency:copy -Dartifact=$artifact -DoutputDirectory=$outputdir 

## show file
#filename="$outputdir/$artifact_ok"
#filename=${filename#${PWD}/}
filename=${outputdir#${PWD}/}
ls $filename/*.jar -l 2> /dev/null


## TODO
## get com.jfeat group-id  within .jar
