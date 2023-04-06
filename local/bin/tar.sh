#!/usr/bin/env bash
## test array
#arr=(foo bar)
# #remove the latest arg
#unset "arr[${#arr[@]}-1]"
# echo ${#arr[@]}
#echo ${arr[@]}
#exit 2
################1

## get name for snapshot
# currdir=${PWD}
# archiva=${currdir##*\/}
# archive=$archiva-SNAPSHOT.tar
IGNORE='_tarignore'
ignore='.tarignore'

dir=$(dirname $(realpath $0))
if [ ! -f $ignore ];then
   cp $dir/$IGNORE ./$ignore
fi



## read archive config files
exclude_array=()
readignorelines(){
   input="${PWD}/$ignore"
   if [ -f $input ];then
      while IFS= read -r line
      do
        # echo "$line"

        # skip comment
        if [[ $line = \#* ]];then
           continue
        fi
        exclude_array+=("$line")
      done < "$input"
   fi
   exclude_array+=("$ignore")
}

buildexcludeline(){
    exline=""
    if [ ${#exclude_array[@]} -gt 0 ];then
        ## exclude ...
        for str in ${exclude_array[@]};do
            local exclude=" --exclude=$str"
            exline="$exline $exclude"
        done
    fi
    echo $exline
}

readignorelines
exclude_line=$(buildexcludeline)


last_arg=${@: -1}
args=($@)
unset "args[${#args[@]}-1]"

# echo tar ${args[@]} $exclude_line $last_arg
tar ${args[@]} $exclude_line $last_arg






# tar -cvf  $archive \
#     --exclude=*.jar --exclude=*.jar.* --exclude=*.war  --exclude=*rollback* \
#     --exclude=./*mysql*/data/* \
#     --exclude=./web/dist \
#     --exclude=*.log --exclude=*logs* \
#     --exclude=*.gz --exclude=*.tar --exclude=*.swp \
#     --exclude=.git \
#     --exclude=node_modules \
#     --exclude=.idea \
#     --exclude=.ssh/ --exclude=.cache/ --exclude=.profile --exclude=.bashrc \
#     . 

# ## add ./api/app.jar
# if [ -f ./api/app.jar ];then
#    echo step 2 => pack ./api/app.jar
#    tar -uvf $archive ./api/app.jar 
# else
#    echo warning: no ./api/app.jar found !
# fi

# ## add web/dist
# if [ -d ./web/dist ];then
#    echo step 2 => pack ./web/dist
#    tar -uvf $archive ./web/dist
# else
#    echo warning: no ./web/dist found !
# fi

# echo '=> add api/app.jar or web/dist manually'
# echo tar -uvf $archive ./api/app.jar
# echo tar -uvf $archive ./web/dist


