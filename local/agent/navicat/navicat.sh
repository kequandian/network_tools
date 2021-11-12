#!/bin/sh
#echo mysql listing on :23336 [:3306] ...

#!/bin/sh
usage(){
   echo "usage: navicat.sh [start|stop|console]"
   exit
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
        docker-compose -f $dir/share/navicat.yml down
     fi
     docker-compose -f $dir/share/navicat.yml up $detach
  fi
}


## main
opt=$1

if [ ! $opt ];then
   usage
fi

if [ "$opt"x = "start"x ];then
   run -d 
elif [ "$opt"x = "console"x ];then
   echo console mode
   echo navicat listing on 0.0.0.0:23306 ...
   run --rm 
elif [ "$opt"x = "stop"x ];then
   docker stop navicat
else
   usage
fi