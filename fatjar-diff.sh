#!/usr/bin/env bash
script_path(){
   local path
   osname=$(uname)
   if [ $osname = Darwin ];then  ## MAC
      path=$(greadlink -f "$0")
   else                                ## Windows
      path=$(readlink -f "$0")
   fi
   echo $(dirname $path)
}

java -jar $(script_path)/local/lib/jar-dependency.jar $@