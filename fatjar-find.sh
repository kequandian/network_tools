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

   # echo curl -s http://${DUMMY_HOST}:${DUMMY_PORT}/containers/${DUMMY_CONTAINER}/json > /dev/stderr
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
dir=$(dirname $(realpath $0))
if [ ! $dir ];then
  dir='.';
fi
JAR_BIN=$(which jar 2> /dev/null)
if [ ! $JAR_BIN ];then
   export PATH=$PATH:$dir
   JAR_BIN="jar.sh"
fi

getfatjar(){
  local working_dir=$(workingdir)
  if [ ! $working_dir ];then
     echo "failure: working_dir not set !" > /dev/stderr
     exit
  fi
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/app.jar $working_dir/*.war 2> /dev/null)
  if [ -z "$standalone" ];then
     exit
  fi
  echo $standalone
}

## main
pattern=$1
if [ ! $pattern ];then 
  echo 'usage: fatjar-find <pattern>'
  exit
fi
fatjar=$(getfatjar)
if [ -z "$fatjar" ];then 
  echo no fatjar found ! > /dev/stderr
  exit
fi

# start
# echo start searching ... $pattern > /dev/stderr
if [ $pattern = '.' ];then
# echo "$JAR_BIN" tf $fatjar
"$JAR_BIN" tf $fatjar
else
# echo "$JAR_BIN tf $fatjar | grep $pattern"
"$JAR_BIN" tf $fatjar | grep $pattern
fi

