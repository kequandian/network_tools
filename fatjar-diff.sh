#!/usr/bin/env bash
script_path(){
   local path
   osname=$(uname)
   if [ $osname = Darwin ];then  ## MAC
      path=$(greadlink -f "$0")
   else                          ## Windows
      path=$(readlink -f "$0")
   fi
   echo $(dirname $path)
}
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

## check
args=()
unset jar1
unset jar2
working_dir=$(workingdir)
for jar in $@;do
   j=${jar::1}
   if [ $j = '-' ];then
     args=(" $jar")
   else
     if [ ! $jar1 ];then
        jar1=$working_dir/$jar
        args+=($jar1)
      #   args=("${args[@]}" $jar1)
     elif [ $jar1 -a ! $jar2 ];then
        jar2=$working_dir/$jar
        args+=($jar2)
     fi
   fi
done

java -jar $(script_path)/local/lib/jar-dependency.jar ${args[@]}
