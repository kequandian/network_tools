#!/usr/bin/env bash
ignore='.tarignore'

dir=$(dirname $(realpath $0))

if [ ! -f $ignore ];then
   cp $dir/$ignore .
fi

usage(){
    echo "usage: tar-snapshot.sh <target>"
    exit
}

if [ ! $1 ];then 
   usage
fi

target=$1
target_name=$target
if [[ $target = '.' ]];then 
   target_name=$(basename $(realpath $0))
fi

$dir/tar.sh cvf $target_name-$(date "+%m-%d").tar $target
