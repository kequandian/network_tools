#!/bin/sh
usage(){
   echo "usage: socat.sh [start|stop|console]"
   exit
}

run() {
  detach=$1

  socat=$(docker ps -a --format '{{.Names}}' | grep socat)
  if [ "$detach"x = "-d"x -a "$socat"x = "socat"x ];then
     docker start socat
  else
     if [ "$socat"x = "socat"x ];then
        docker stop socat 2> /dev/null
        docker rm socat 2> /dev/null
     fi
     docker run $detach  -v /var/run/docker.sock:/var/run/docker.sock --name socat -p 2375:2375 alpine/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
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
   echo socat listing on 0.0.0.0:2375 ...
   run --rm 
elif [ "$opt"x = "stop"x ];then
   docker stop socat
else
   usage
fi

