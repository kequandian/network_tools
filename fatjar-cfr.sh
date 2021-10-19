#!/usr/bin/env bash
JAR_BIN=$(which jar)
JAVA_BIN=$(which java)
CFR_JAR_VERSION='cfr-0.151.jar'
CFR_JAR_LIB="./local/lib/$CFR_JAR_VERSION"

downloadcfr() {
  echo curl -sL https://www.benf.org/other/cfr/$CFR_JAR_VERSION -o $CFR_JAR_LIB
  curl -sL https://www.benf.org/other/cfr/$CFR_JAR_VERSION -o $CFR_JAR_LIB
  ls $CFR_JAR_LIB
}

getlocaljars(){
  jars=$(ls BOOT-INF/lib/*.jar WEB-INF/lib/*.jar data/lib/*.jar 2> /dev/null)
  if [ -z "$jars" ];then
     exit
  fi
  echo $jars
}


## main
pattern=$1
opt=$2; if [ ! $opt ];then opt='z'; fi
if [ ! $pattern ];then 
  echo 'usage: fatjar-cfr <pattern> [-]'
  echo ' -   --force to get latest .class'
  exit
fi
jars=$(getlocaljars)
if [ -z "$jars" ];then 
  echo no fatjar found ! > /dev/stderr
  exit
fi

# start
for jar in $jars;do
  echo + $jar
  if [ $pattern = '.' ];then
  result=$("$JAR_BIN" tf $jar)
  else
  result=$("$JAR_BIN" tf $jar | grep $pattern)
  fi
  if [ -z "$result" ];then 
     continue
  fi

  num=0
  for entry in $result;do
    echo $entry
    num=$(($num+1))
  done
  if [ $num = 1 ];then
    # ensure cfr-0.151.jar exist
    if [ ! -f $CFR_JAR_LIB ];then
       downloadcfr
    fi
    if [ ! -f $CFR_JAR_LIB ];then
       echo "$CFR_JAR_LIB not exist !" > /dev/stderr
       exit
    fi
    ## end check

    if [ $opt = '-' -o ! -f $result ];then
       "$JAR_BIN" xf $jar $result
    fi
    "$JAVA_BIN" -jar $CFR_JAR_LIB $result
  fi
done
