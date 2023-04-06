#!/usr/bin/env bash

standalone=$1
javaclass=$2
if [ ! $javaclass ];then
  echo "usage: cfr <standalone> <javaclass:[pattern]>"
  exit
fi

if [ ! -f $1 ];then
  echo $standalone not exists !
  exit
fi

dir=$(dirname $(realpath $0))
if [ ! $dir ];then
  dir='.';
fi
JAR_BIN=$(which jar)
if [ ! $JAR_BIN ];then
   JAR_BIN="$dir/jar.sh"
fi

## check jarlib ok
jars=$($JAR_BIN tf $standalone | grep .jar)
jarsnum=${#jars[*]}
if [ $jarsnum -gt 0 ];then

    for jarok in $jars;do
        #echo jar xf $standalone $jarok
        if [ ! -e $jarok ];then
           $JAR_BIN xf $standalone $jarok
        fi
        
        if [ -f $jarok ];then
            ## check javaclass ok
            javaclassok=$($JAR_BIN tf $jarok | grep .class | grep -i $javaclass)
            javaclassok=(${javaclassok/ })  ## convert string into array

            num=${#javaclassok[*]}
            if [ $num -eq 0 ];then
              echo $jarok > /dev/null   
            elif [ $num -gt 1 ];then 
                echo pattern $javaclass includes multi java class !
                echo $jarok
                echo ${javaclassok[*]}
                exit
            else
                echo $jarok
                echo $javaclassok
                exit
            fi
        fi
    done

else
    echo .jar not found in $standalone 
fi 