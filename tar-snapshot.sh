#!/usr/bin/env bash
## this tool used in anywhere to package any path, 
## install it into /usr/local/bin/tar-snapshot.sh before use it 
## e.g.
## cp ./local/bin/tar-snapshot.sh /usr/local/bin/tar-snapshot.sh
## chmod +x /usr/local/bin/tar-snapshot.sh
## usage
## vi .tarignore in current path to ignore types of file or path

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
