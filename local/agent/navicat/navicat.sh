#!/usr/bin/env bash
usage(){
   echo "usage: ORIGIN=<Container>[:port] navicat.sh [start|stop|console]"
   echo '   e.g.  ORIGIN=mysqlserver navicat.sh console'
   exit
}

get_container_network(){
   cont=$1
   echo $(docker inspect smartsee --format '{{range $k, $v := .NetworkSettings.Networks}}{{printf "%s" $k}}{{end}}')
}

fixconf(){
   origin=$1
   dir=$2

   server=${origin%:*}
   port=${origin#*:}
   if [[ ! $port || $port = $server ]];then 
      port='3306'
   fi
   network=host
   container=$9

   if [[ $server =~ ^[0-9\.]+ ]];then
      ## do nothing
      server=$server
   else
      # consider as container, get network from container
      container=$server
   fi
   
   ## handle container
   if [ $container ];then
      network=$(get_container_network $container)
   fi

   ## fix conf.d/*.mod
   local target="$dir/share/conf.d/mysql-expose.mod"
   cp $dir/share/conf.d/mysql-expose.mod.sample $target
   sed -i "s/    server[[:space:]]*mysqlserver:3306;/    server $server:$port;/"  $target
   ## end fix conf


   echo $network    
}

run() {
  detach=$1

  navicat=$(docker ps -a --format '{{.Names}}' | grep navicat)
  if [ "$detach"x = "-d"x  -a  "$navicat"x = "navicat"x ];then
     docker start navicat
  else
     local dir=$(dirname $(readlink -n $0) 2> /dev/null)
     if [ ! $dir ];then
        dir='.'
     fi
     if [ "$navicat"x = "navicat"x ];then
        echo docker-compose -f $dir/share/navicat.yml down
        docker-compose -f $dir/share/navicat.yml down
     fi

     ## attach origin mysql server
     local network=$(fixconf ${ORIGIN} $dir)

     echo docker-compose -f $dir/share/navicat.yml up $detach
     NETWORK=$network docker-compose -f $dir/share/navicat.yml up $detach
  fi
}


## main
opt=$1

if [ ! $opt ];then
   usage
fi
if [ ! ${ORIGIN} ];then 
   echo env ORIGIN not yet defined !
   usage
fi

## fix cond.d/mysql-expose.mod first
if [ "$opt"x = "start"x ];then
   echo navicat listing on 0.0.0.0:23306 ...
   run -d 
elif [ "$opt"x = "console"x ];then
   echo console mode
   echo navicat listing on 0.0.0.0:23306 ...
   run 
elif [ "$opt"x = "stop"x ];then
   docker stop navicat
else
   usage
fi
