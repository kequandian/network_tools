#!/usr/bin/env bash
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

dir=$(dirname $(realpath $0))
if [ ! $dir ];then 
  dir='.'
fi
java -jar $dir/local/lib/jar-dependency.jar ${args[@]}
