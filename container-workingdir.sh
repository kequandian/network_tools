#!/bin/sh
usage(){
  echo 'usage: CONAINER=<container> container-workingdir'
  exit
}

container=${CONTAINER}
if [ ! $container ];then
   usage
fi

ENDPOINT="http://localhost"  # for SOCK_OPT
SOCK_OPT='--unix-socket /var/run/docker.sock'

getcontainerjsonvalue(){
   endpoint=$1
   container=$2
   jq_filter="$3"

   # echo "curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match(\"([a-z/]+):[a-z/]*/webapps[a-z/]*\").string'"
   # local binds=$(curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
   echo "curl $SOCK_OPT -s $endpoint/containers/$container/json | jq $jq_filter" > /dev/stderr
   local result=$(curl $SOCK_OPT -s $endpoint/containers/$container/json | jq $jq_filter)
   result=${result%\"}
   result=${result#\"}
   #if [[ $result = null ]];then
   #  result=''
   #fi
   echo $result
}

# working dir from filesystem
getcomposeworkingdir(){
   endpoint=$1
   container=$2
   echo $(getcontainerjsonvalue $endpoint $container '.Config.Labels."com.docker.compose.project.working_dir"')
}

getworkingdir(){
   endpoint=$1
   container=$2

   # echo "curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match(\"([a-z/]+):[a-z/]*/webapps[a-z/]*\").string'"
   # local binds=$(curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
   echo "curl $SOCK_OPT -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match(\"[a-z_/]*:/webapps*\").string'" > /dev/stderr
   local binds=$(curl $SOCK_OPT -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("[a-z_/]*:/webapps*").string')
   # for workingdir_nginx
   #local binds=$(curl $SOCK_OPT -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("[a-z/]*/usr/share/nginx/html:rw").string')

   for bind in $binds;do
      bind=${bind%\"}
      bind=${bind#\"}
      bind=${bind%:rw}
      bind=${bind%:/webapps}
      echo $bind
    done
}


## MAIN

echo $(getworkingdir $ENDPOINT $container)

