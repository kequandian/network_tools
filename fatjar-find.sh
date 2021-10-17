#!/usr/bin/env bash
if [ -f .env ];then source .env;fi
working_dir=${DUMMY_WORKING_DIR}
JAR_BIN=$(which jar)

getfatjar(){
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/*.war 2> /dev/null)
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
