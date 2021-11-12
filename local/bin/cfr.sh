#!/usr/bin/env bash
## https://www.benf.org/other/cfr/
## curl -sLO https://www.benf.org/other/cfr/cfr-0.151.jar
downloadcfr() {
  cfrjar=$1
  currdir=$(pwd)
  if [ ! -f $cfrjar  ];then
     cd $(dirname $cfrjar)
     curl -sLO https://www.benf.org/other/cfr/cfr-0.151.jar
     cd $currdir
  fi
}
dir=$(dirname $(realpath $0))
if [ ! $dir ];then
  dir='.';
fi
JAVA_BIN=$(which java)
JAR_BIN=$(which jar)
CFR_JAR_VERSION='cfr-0.151.jar'
if [ ! $JAR_BIN ];then
   JAR_BIN="$dir/jar.sh"
fi
if [ ! $JAVA_BIN ];then
   JAVA_BIN="$dir/jar.sh"
fi

downloadcfr $CFR_JAR


##################################
## main
##################################

## pattern
fatjar=$1
javaclass=$2
if [ ! $javaclass ];then
  echo "usage: cfr <fatjar> <pattern>"
  exit
fi
if [ ! -f $fatjar ];then
  echo $fatjar file not exists !
  exit
fi


## check jarlib ok
jarok=$($JAR_BIN tf $standalone | grep jar | grep -i $jarlib)
if [ $jarok ];then
    echo $jarok
    ## do jar 0uf
    #if [ ! -e $jarok ];then
       echo jar xf $standalone $jarok
       $JAR_BIN xf $standalone $jarok
    #fi

    if [ -f $jarok ];then
        ## check javaclass ok
        javaclassok=$($JAR_BIN tf $jarok | grep .class | grep -i $javaclass )
        javaclassok=(${javaclassok/ })  ## convert string into array

        num=${#javaclassok[*]}
        if [ $num -gt 1 ];then 
          echo pattern $javaclass includes multi java class !
          echo ${javaclassok[*]}
          exit
        fi

        echo $javaclassok
        echo jar xf $jarok $javaclassok
        $JAR_BIN xf $jarok $javaclassok
        ls $javaclassok
        echo ............................
        echo 
        java -jar /usr/local/lib/cfr-0.151.jar $javaclassok
    fi
fi 
