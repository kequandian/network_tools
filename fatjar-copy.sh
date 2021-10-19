#!/usr/bin/env bash
### start get working_dir
# if [ -f .env ];then source .env;fi
# working_dir=${DUMMY_WORKING_DIR}
# echo working_dir= $working_dir
workingdir(){
   if [ ! $DUMMY_CONTAINER ];then
      if [ -f .env ];then source .env;fi
   fi
   curl -s http://localhost:2375/containers/${DUMMY_CONTAINER}/json | jq '.HostConfig.Binds[] | match("([a-z/]+):/webapps") | .captures[0].string'
}
working_dir=$(workingdir)
working_dir=${working_dir%\"}
working_dir=${working_dir#\"}
# echo working_dir= $working_dir
## end workding_dir

JAR_BIN=$(which jar)

getfatjar(){
  standalone=$(ls $working_dir/*-standalone.jar $working_dir/app.jar $working_dir/*.war 2> /dev/null)
  if [ -z $standalone ];then
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
