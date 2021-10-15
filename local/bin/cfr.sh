#!/usr/bin/env bash
## https://www.benf.org/other/cfr/
## curl -sLO https://www.benf.org/other/cfr/cfr-0.151.jar
JAVA_BIN=$(which java)
JAR_BIN=$(which jar)

CFR_JAR_VERSION='../lib/cfr-0.151.jar'
CFR_JAR="../lib/$CFR_JAR_VERSION"
CFR_BIN="$JAVA_BIN -jar $CFR_JAR"


## only standalone
if [ ! $2 ];then
if [ -f $1 ];then
   javaclass=$1
   javaclass=${javaclass##*.}

   if [ "$javaclass"x = "class"x ];then
      $CFR_BIN $@
   fi
   exit
fi
fi

## main

## pattern
standalone=$1
jarlib=$2
javaclass=$3
if [ ! $javaclass ];then
  echo "usage: cfr <standalone> <jarlib:[pattern]> <javaclass:[pattern]>"
  exit
fi

if [ ! -f $1 ];then
  echo $standalone not exists !
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

else
    echo $jarlib not found in $standalone 
fi 