#!/usr/bin/bash
######################
deploy_container=${CONTAINER}
####################
usage(){
   echo 'usage: CONTAINER=<container> deploy-fatjar.sh <target>'
   exit 
}

if [ ! $deploy_container ];then 
   usage
fi
#########################

ENDPOINT="http://localhost"
SOCK_OPT='--unix-socket /var/run/docker.sock'

# ## working dir within container => /webapps
# workingdir(){
#    endpoint=$1
#    container=$2

#    # echo "curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match(\"([a-z/]+):[a-z/]*/webapps[a-z/]*\").string'"
#    # local binds=$(curl -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("([a-z/]+):[a-z/]*/webapps[a-z/]*").string')
#    echo curl $SOCK_OPT -s $endpoint/containers/$container/json > /dev/stderr
#    local binds=$(curl $SOCK_OPT -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("[a-z/]*/webapps:rw").string')
#    # for workingdir_nginx
#    local binds=$(curl $SOCK_OPT -s $endpoint/containers/$container/json | jq '.HostConfig.Binds[] | match("[a-z/]*/usr/share/nginx/html:rw").string')
#    for bind in $binds;do
#       bind=${bind%\"}
#       bind=${bind#\"}
#       bind=${bind%:rw}
#       echo $bind
#    done
# }

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
   echo $result
}

# working dir from filesystem
getcomposeworkingdir(){
   endpoint=$1
   container=$2
   echo $(getcontainerjsonvalue $endpoint $container '.Config.Labels."com.docker.compose.project.working_dir"')
}

getcontainerstatus(){
   endpoint=$1
   container=$2
   echo $(getcontainerjsonvalue $endpoint $container '.State.Status')
}

stopcontainer(){
    endpoint=$1
    container=$2
    echo curl $SOCK_OPT -s -X POST $endpoint/containers/$container/stop > /dev/stderr
    curl $SOCK_OPT -s -X POST $endpoint/containers/$container/stop
}
restartcontainer(){
    endpoint=$1
    container=$2
    echo curl $SOCK_OPT -s -X POST $endpoint/containers/$container/restart > /dev/stderr
    curl $SOCK_OPT -s -X POST $endpoint/containers/$container/restart
}

# puttartocontainer(){
#    endpoint=$1
#    container=$2
#    working_dir=$3
#    tarbin=$4

#    echo curl $SOCK_OPT -X PUT ${endpoint}/containers/${container}/archive?path=$working_dir -H \'Content-Type: application/x-tar\' --data-binary @$tarbin > /dev/stderr
#    curl $SOCK_OPT -X PUT ${endpoint}/containers/${container}/archive?path=$working_dir -H 'Content-Type: application/x-tar' --data-binary @$tarbin
#    rm -f $tarbin
# }

buildtar(){
   targetpath=$1

   local dir=${targetpath%\/*}
   local target=${targetpath##*\/}
   if [[ $dir = $target ]];then
      dir='.'
   fi

   wdir=${PWD}
   cd $dir
   if [ ! -f $target.tar.gz ];then
      echo tar zcvf $target.tar.gz $target > /dev/stderr
      tar zcvf $target.tar.gz $target > /dev/null
   fi
   cd $wdir
   echo $targetpath.tar.gz
}

## locate deploy target: [*-standalone.jar, index.html]
locatedeploytarget(){
   target=$1
   local webresult=$(ls $target/index.html 2> /dev/null)
   if [ ! -z "$webresult" ];then
      if [ -f $webresult ];then 
         echo $target
         return
      fi
   fi

   cd $target
   local result=$(ls *-standalone.jar 2> /dev/null)
   if [ -z "$result" ];then
      echo "$result not found !" > /dev/stderr
      exit
   fi
   if [ ! -f "$result" ];then 
      echo "multi standalone found: $result !" > /dev/stderr
      exit
   fi
   echo $result
}

#########################################################################
### start deploy
deploytarget(){
   local target=$1

   ## get deploy target
   deploy_target=$(locatedeploytarget $target)
   if [ ! $deploy_target ];then
      echo fail to locate deploy target ! > /dev/stderr
      exit
   fi

   ## build tar
   # tarbin=$(buildtar $deploy_target)
   
   ## put standalone 
   echo deploying $deploy_target ..
   # working_dir=$(workingdir $ENDPOINT $deploy_container 2> /dev/null)
   # puttartocontainer $ENDPOINT $deploy_container $working_dir $tarbin
   ## local deploy
   filesystem_workingdir=$(getcomposeworkingdir $ENDPOINT $deploy_container 2> /dev/null)
   # app=${deploy_target#*/}
   target_op='web'  ## web or jar
   if [[ $deploy_target = *.jar ]];then 
      target_op='jar'
   fi

   ## fix filesystem_workingdir
   if [[ $target_op = jar && -d $filesystem_workingdir/api ]];then
      filesystem_workingdir=$filesystem_workingdir/api
   fi
   ## end fix filesystem_workingdir

   echo ls -l $filesystem_workingdir/$deploy_target
   ls -l $filesystem_workingdir/$deploy_target
   if [[ $target_op = web ]];then 
      echo rm -rf $filesystem_workingdir/$deploy_target
      rm -rf $filesystem_workingdir/$deploy_target
      echo cp -r $deploy_target $filesystem_workingdir
      cp -r $deploy_target $filesystem_workingdir
   else
      echo rm -rf $filesystem_workingdir/$deploy_target
      rm -rf $filesystem_workingdir/$deploy_target
      ## $target/$deploy_target vs. $deploy_target
      echo cp $target/$deploy_target $filesystem_workingdir
      cp $target/$deploy_target $filesystem_workingdir      
   fi
   ls -l $filesystem_workingdir/$deploy_target
}
### end deploy
#########################################################################



### ################################
### main
####################################
usage(){
   echo 'usage: CONTAINER=<container> deploy-fatjar [OPTIONS] <target>'
   echo ''
   echo '[OPTIONS]:'
   echo '  -h --help          --print usage'
   echo '  -r --restart       --restart container only'
   exit 0
}

target_opt=$9
restart_opt=$9
for opt in $@;do
   if [[ $opt = '-h' || $opt = '--help' ]];then 
     usage
   elif [[ $opt = '-r' || $opt = '--restart' ]];then 
     restart_opt=$opt
   else 
     target_opt=$opt
   fi
done
## check option
if [ $restart_opt ];then 
   echo "restarging $deploy_container"
   unset $target_opt
elif [ $target_opt ];then
   if [ ! -e $target_opt ];then 
      #echo $target_opt not exists ! >  /dev/stderr
      #exit -1
      usage
   fi
else 
   target_opt='target'
   if [ ! -e $target_opt ];then 
      #echo $target_opt not exists ! >  /dev/stderr
      #exit -1
      usage
   fi
fi

## stop container first
echo stopping container $deploy_container ..
stopcontainer $ENDPOINT $deploy_container
status=$(getcontainerstatus $ENDPOINT $deploy_container)
if [[ ! $status = 'exited'  ]];then
   echo "fatal: fail to stop $deploy_container: $status !"
   exit
fi
echo stopped: $status !

## restart or deploy
if [ $target_opt ];then 
   deploytarget $target_opt
fi

## restart container
echo restarting container $deploy_container ..
restartcontainer $ENDPOINT $deploy_container

status=$(getcontainerstatus $ENDPOINT $deploy_container)
echo restarted: $status ..

