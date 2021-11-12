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
dir=$(dirname $(realpath $0))
if [ ! $dir ];then
  dir='.';
fi
JAR_BIN=$(which jar)
if [ ! $JAR_BIN ];then
   JAR_BIN="$dir/jar.sh"
fi

getfatjar(){
  local working_dir=$(workingdir)
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/app.jar $working_dir/*.war 2> /dev/null)
  if [ -z $standalone ];then
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
if [ $pattern = '.' ];then
"$JAR_BIN" tf $fatjar
else
"$JAR_BIN" tf $fatjar | grep $pattern
fi
