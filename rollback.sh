#/usr/bin/env bash
rollbackkeep() {
   pattern=$1
   num=$2
   
   result=$(ls "$pattern" -t 2> /dev/null)
   i=1
   for it in $result;do
      if [ $i -gt $num ];then
        echo $it
        rm -f $it
      fi
      ## increase
      i=$(($i+1))
   done
}

findstandalone(){
   local target=$1

   ## check if path or file
   if [ -d $target ];then
      # cd $target
      local result=$(ls $target/*-standalone.jar $target/app.jar $target/*.war 2> /dev/null)
      if [ -z "$result" ];then
         echo "no standalone not found within: $target !" > /dev/stderr
         exit -1
      fi
      if [ ! -f "$result" ];then 
         echo "multi standalone found: " > /dev/stderr
         for v in $result;do
            # echo $result
            echo $v > /dev/stderr
         done
         exit -1
      fi
      echo $result
   else 
      echo $target
   fi
}

checksame(){
   app1=$1
   app2=$2
#    echo app1=$app1, app2=$app2 > /dev/stderr
   
   app1_sum=$(sha256sum $app1)
   app1_sum=${app1_sum%% *}
   app2_sum=$(sha256sum $app2)
   app2_sum=${app2_sum%% *}
    #   echo app1_sum=$app1_sum, app2_sum=$app2_sum > /dev/stderr

   if [[ $app1_sum = $app2_sum ]];then
       echo $app1_sum
   fi
}

try_checksame(){
   app=$1
   rollback_path=$2
   DIR=${rollback_path%\/*}
   ROLLBACK=${rollback_path##*/}   ## the name 
   if [[ $DIR = $ROLLBACK ]];then 
      ## means no dir
      DIR='.'
   fi

   ## ROLLBACK exists, check if sha256 the same
   shasum=$(checksame $app $rollback_path)
   if [ ! -z $shasum ];then
       # is the same jar, just return 
       #echo "no rollback required, the same rollback $app_dir/$ROLLBACK exists !" > /dev/stderr
       echo $ROLLBACK\@sha256:$shasum@duplicated > /dev/stderr
       echo $shasum
       return
   fi

   ## continue to check the latest rollback
   latest_rollback=$(ls $DIR/*.rollback* -t | head -1)
   shasum=$(checksame $app $latest_rollback)
   if [ ! -z $shasum ];then
      ROLLBACK=${latest_rollback##*/}   ## the name 
       # is the same jar, just return 
       #echo "no rollback required, the same rollback $app_dir/$ROLLBACK exists !" > /dev/stderr
       echo $ROLLBACK\@sha256:$shasum@duplicated > /dev/stderr
       echo $shasum
   fi
}

rollback() {
   local target=$1
   local tag=$2

   # ## for what???
   # if [ -d $target ];then 
   #    echo tar zcvf $target.tar.gz $target > /dev/stderr
   #    target=$target.tar.gz
   # fi
   # ### ??? comment out
   ## check if file or dir
   standalone=$(findstandalone $target)
   if [ -z $standalone ];then 
      exit -1
   fi
   target=$standalone

   ## check dir
   app_dir=${target%\/*}
   app_name=${target##*\/}
   if [[ $app_dir = $app_name ]];then 
      ## means no dir
      app_dir='.'
   fi

   ##########################
   ##### dayly
   ##########################

   ROLLBACK=$app_name-$(date "+%Y-%m-%d").rollback
   if [ $tag ];then
      ROLLBACK=${target%.rollback}
      ROLLBACK="$ROLLBACK..$tag.rollback"
   fi
   if [ ! -f $app_dir/$ROLLBACK ];then
       #echo cp $target $app_dir/$ROLLBACK > /dev/stderr
       cp $target $app_dir/$ROLLBACK
       echo "$app_dir/$ROLLBACK"
       return
   fi

   ## ROLLBACK exists, check if sha256 the same
   checksame=$(try_checksame $target $app_dir/$ROLLBACK)
   if [ $checksame ];then 
      return
   fi

   ##### hourly
   ## means not the same file, get the hourly ROLLBACK
   ROLLBACK=$app_name.$(date "+%Y-%m-%d").rollback
   if [ $tag ];then
      ROLLBACK=${target%.rollback}
      ROLLBACK="$ROLLBACK..$tag.rollback"
   fi
   if [ ! -f $app_dir/$ROLLBACK ];then
       #echo cp $target $app_dir/$ROLLBACK > /dev/stderr
       echo cp $target $app_dir/$ROLLBACK > /dev/stderr
       cp $target $app_dir/$ROLLBACK
       echo $ROLLBACK
       return
   fi
   ## ROLLBACK exists, check if sha256 the same
   checksame=$(try_checksame $target $app_dir/$ROLLBACK)
   if [ $checksame ];then 
      return
   fi

   ##### minutely
   ## means not the same file, get the minutely ROLLBACK
   ROLLBACK=$app_name.$(date "+%Y-%m-%d").rollback
   if [ $tag ];then
      ROLLBACK=${target%.rollback}
      ROLLBACK="$ROLLBACK..$tag.rollback"
   fi
   if [ ! -f $app_dir/$ROLLBACK ];then
       #echo cp $target $app_dir/$ROLLBACK > /dev/stderr
       cp $target $app_dir/$ROLLBACK
       echo $ROLLBACK
       return
   fi
   ## ROLLBACK exists, check if sha256 the same
   checksame=$(try_checksame $target $app_dir/$ROLLBACK)
   if [ $checksame ];then 
      return
   fi

   ##### still the same
   echo "$ROLLBACK exists, pls wait for one more minute !" > /dev/stderr
}


## main
# keep=${ROLLBACK_KEEP_NUM}  # keep rollback instances

usage(){
    echo "usage: rollback.sh [OPTIONS] <target>"
    echo 'target'
    echo '   where the target artifact locate, or the artifact file'
    echo " OPTIONS:"
    echo "   -t  --tag  <tag>      addtional data for rollback"
    echo "   -k  --keep <NUM>      keep the rollback instance within <NUM>"
    exit
}
if [ ! $1 ];then
   usage
fi

target=$9
tag_opt=$9
tag=$9
keep_opt=$9
keep_num=$9
for op in $@;do
   if [[ $op = '-t' || $op = '--tag' ]];then 
     tag_opt=$op
   elif [ $tag_opt ];then
     tag=$op
     unset tag_opt
   elif [[  $op = '-k' || $op = '--keep' ]];then 
     keep_opt=$op
   elif [[ $keep_opt ]];then
     keep_num=$op
     unset keep_opt
   else
     target=$op
   fi
done
if [ ! $target ];then 
   usage
fi

## start
echo start rollback within: $target $tag > /dev/stderr
rollback_result=$(rollback $target $tag)
# echo rollback_result=$rollback_result
if [ ! -z "$rollback_result" ];then 
   rollback_pattern=${rollback_result%.jar*}
   rollback_pattern=$rollback_pattern.jar.*.rollback*

   ## show rollback result
   rollback_dir=${rollback_result%\/*}
   ls $rollback_dir/*.rollback* -t 2> /dev/null
   echo rollbackkeep $rollback_pattern $keep_num > /dev/stderr
   rollbackkeep $rollback_pattern $keep_num
   ls $rollback_dir/*.rollback* -t 2> /dev/null
fi
# echo > /dev/stderr
# echo done > /dev/stderr
