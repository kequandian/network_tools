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
working_dir=$(workingdir)
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
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/app.jar $working_dir/*.war 2> /dev/null)
  if [ -z "$standalone" ];then
     exit
  fi
  echo $standalone
}

## main
pattern=$1
outputdir=$2
if [ ! $pattern ];then 
  echo 'usage: fatjar-copy <pattern>'
  exit
fi
fatjar=$(getfatjar)
if [ -z "$fatjar" ];then 
  echo + $working_dir
  echo no fatjar found ! > /dev/stderr
  exit
fi

# start
result=$("$JAR_BIN" tf $fatjar | grep $pattern)
num=0
for entry in $result;do
   echo $entry
   num=$(($num+1))
done

if [ $num = 1 ];then 
  resultok=$("$JAR_BIN" xf $fatjar $result)
  echo $resultok
elif [ $num = 0 ];then
  echo "no matches \"$pattern\" in $fatjar !" > /dev/stderr  
fi
