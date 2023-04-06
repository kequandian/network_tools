#!/usr/bin/env bash
usage(){
    echo "usage: tar-snapshot.sh <target>"
    exit
}
if [ ! $1 ];then 
   usage
fi

## main
target=$1
target_name=$target
if [[ $target = '.' ]];then 
   #target_name=$(basename ${PWD})
   target_name=${PWD}
   target_name=${target_name##*\/}
fi

dir=$(dirname $(realpath $0))
$dir/tar.sh cvf ${target_name}_$(date "+%Y-%m-%d").tar $target
