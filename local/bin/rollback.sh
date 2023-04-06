#/usr/bin/env bash

usage(){
    echo "usage: rollback.sh <standalone>"
    exit
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

rollback() {
   local app_war=$1
   app_dir=${app_war%\/*}
   app_name=${app_war##*\/}
#    app_sum=$(sha256sum $app_war)
#    app_sum=${app_sum%% *}

   ##### dayly
   ROLLBACK=$app_name.rollback_$(date "+%m-%d")
   if [ ! -f $app_dir/$ROLLBACK ];then
       echo cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       echo $ROLLBACK
       return
   fi
   ## ROLLBACK exists, check if sha256 the same
   shasum=$(checksame $app_war $app_dir/$ROLLBACK)
   if [ ! -z $shasum ];then
       # is the same jar, just return 
       echo $shasum $app_dir/$ROLLBACK> /dev/stderr
       return 
   fi

   ##### hourly
   ## means not the same file, get the hourly ROLLBACK
   ROLLBACK=$app_name.rollback_$(date "+%m-%d-%H")
   if [ ! -f $app_dir/$ROLLBACK ];then
       echo cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       echo $ROLLBACK
       return
   fi
   ## ROLLBACK exists, check if sha256 the same
   shasum=$(checksame $app_war $app_dir/$ROLLBACK)
   if [ ! -z $shasum ];then
      # is the same jar, just return 
       echo $shasum $app_dir/$ROLLBACK> /dev/stderr
       return 
   fi

   ##### minutely
   ## means not the same file, get the minutely ROLLBACK
   ROLLBACK=$app_name.rollback_$(date "+%m-%d-%H-%M")
   if [ ! -f $app_dir/$ROLLBACK ];then
       echo cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       cp $app_war $app_dir/$ROLLBACK > /dev/stderr
       echo $ROLLBACK
       return
   fi
   ## ROLLBACK exists, check if sha256 the same
   shasum=$(checksame $app_war $app_dir/$ROLLBACK)
   if [ ! -z $shasum ];then
       # is the same jar, just return 
       echo $shasum $app_dir/$ROLLBACK> /dev/stderr
       return 
   fi

   ##### still the same
   echo "$ROLLBACK exists, pls wait for one more minute !" > /dev/stderr
}


if [ ! $1 ];then 
   usage
fi

rollback $@
