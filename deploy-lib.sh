#!/usr/bin/env bash
################################
## put this script to the same path with standalone.jar
## where will deploy the lib .jar within /lib/*.jar into standalone.jar
################################
usage(){
    echo 'usage: CONTAINER=<container> deploy-lib.sh [OPTIONS] <working_dir> <target>'
    echo 'working_dir'
    echo '   whete the fatjar locate'
    echo 'target'
    echo '   where the jar lib locate'
    echo 'OPTIONS:'
    echo '   -h  --help         for help'
    echo '   -f  --force        force to add new jar, default to reject'
    exit -1
}


### ################################
### main
JAR_BIN=$(which jar)
JAVA_BIN=$(which java)
####################################
workingdir_opt=
target_opt=
force_opt=
restart_opt=
for opt in $@;do
  if [[ $opt = -h || $opt = '--help' ]];then
      usage
  elif [[ $opt = -f || $opt = '--force' ]];then
      force_opt=$opt
  elif [[ $opt = '-r' || $opt = '--restart' ]];then 
      restart_opt=$opt
  elif [ $workingdir_opt ];then
      target_opt=$opt
  else
      workingdir_opt=$opt
  fi
done
if [ ! $workingdir_opt ];then
   workingdir_opt=/webapps
fi
if [ ! $target_opt ];then
   target_opt=$workingdir_opt/lib
fi
workingdir=$workingdir_opt
target=$target_opt


## check option
if [ $restart_opt ];then 
   echo "restarging $deploy_container"
   unset $target_opt
elif [ $target_opt ];then
   if [ ! -e $target_opt ];then 
      echo $target_opt not exists ! >  /dev/stderr
      exit -1
   fi
   if [ ! -e $workingdir_opt ];then
      echo $workingdir_opt not exists ! > /dev/stderr
      exit -1
   fi
fi

# ## pending
# ## check dependency from jar-dependency.jar
# checkdependency() {
#   app=$1
#   jar=$2

#   jarlibroot=/usr/local/lib

#   result=$("$JAVA_BIN" -jar $jarlibroot/jar-dependency.jar -cm  $app $jar)
#   echo $result
# }
# ## end pending

putlocaljar(){
  app=$1
  jar=$2
  force=$3  ## for add new jar

   ## check dependency, if required new dependencies, skip
   #      dependencies=$(checkdependency $app $jar)
   #      if [ ${#dependencies} -gt 0 ];then
   #          echo fail to depoy lib for dependencies: >/dev/stderr
   #          for it in $dependencies;do
   #            echo $'\t'$it >/dev/stderr
   #          done
   #          continue
   #      fi
   #   ## end dependency

  ## start deploy jar

  jarlib=$(basename $jar)
  echo + $jarlib > /dev/stderr
  jarok=$("$JAR_BIN" tf $app | grep $jarlib)
    
  if [ ! $jarok ];then
    if [ $force ];then
      ## means new jar
      ## .war for WEB-INF, .jar for BOOT-INF
      local ext=${app##*.}  ##extension of app
      local INF
      if [ $ext = 'war' ];then
        INF=WEB-INF
      else
        INF=BOOT-INF 
      fi
      echo "$INF/lib/$jarlib" > /dev/stderr
      jarok="$INF/lib/$jarlib"
    else
      echo "$jarlib not found in $app, use '-f' to force to add into" > /dev/stderr
      exit 
    fi
  fi
  #echo jarok=$jarok

  if [ $jarok ];then
    ## update lib
    jardir=$(dirname $jarok)
    if [ ! -d $jardir ];then
      echo mkdir -p $jardir > /dev/stderr
      mkdir -p $jardir
    fi

    # core
    echo cp $jar $jardir > /dev/stderr
    cp $jar $jardir

    echo jar 0uf $app $jarok > /dev/stderr
    "$JAR_BIN" 0uf $app $jarok

    ## rm after jar updated
    #echo rm -f $jarok > /dev/stderr
    #rm -f $jarok
  fi
}

## clean up
cleanup() {
  ext=$1
  if [[ $ext = jar ]];then 
    if [ -d BOOT-INF ];then
      rm -rf BOOT-INF/lib/* 2> /dev/null
      rmdir BOOT-INF/lib 2> /dev/null
      rmdir BOOT-INF 2> /dev/null
    fi
  fi
  
  if [[ $ext = war ]];then
    if [ -d WEB-INF ];then
      rm -rf WEB-INF/lib/* 2> /dev/null
      rmdir WEB-INF/lib 2> /dev/null
      rmdir WEB-INF 2> /dev/null
    fi
  fi

  echo rm -f $target/*.jar
  rm -f $target/*.jar 2> /dev/null

  echo rm -f $workingdir/*.FIX
  rm -f $workingdir/*.FIX 2> /dev/null
}

## the only standalone
search_one() {
  pattern=$1

  result=$(ls $pattern 2> /dev/null)
  if [ -z "$result" ];then
    echo no $pattern files found ! > /dev/stderr
    exit
  fi
  if [ ! -f "$result" ];then
    echo multi $pattern files found ! > /dev/stderr
    exit
  fi
  echo $result
}

putlocaljars() {
  app=$1
  libroot=$2
  force=$3  ## for add new jar

  for jar in $(ls $libroot/*)
  do
     # only .jar
     if [[ ! $jar = *.jar ]];then
        continue
     fi
     # skip -standalone.jar
     if [ $jar = *-standalone.jar ];then
        continue
     fi

     putlocaljar $app $jar $force
  done
}

main_deploylib(){
  if [ -z "$(ls $target/*.jar 2>/dev/null)" ];then
    echo 'no lib to deploy !' >/dev/stderr
    exit
  fi

  #check standalone
  standalone=$(search_one $workingdir/"app.jar $workingdir/*-standalone.jar $workingdir/*.war")
  if [ ! $standalone ];then
      echo 'no app.jar, *-standalone.jar, *.war found !' >/dev/stderr
      exit
  fi
  standalone_basename=$(basename $standalone)
  standalone_filename=${standalone_basename%.*}
  standalone_ext=${standalone##*.}
  #echo standalone=$standalone

  ## get fixapp to be deploy
  fixapp=
  if [ $standalone_ext = 'war' ];then
    #fixapp=$standalone_filename.war.FIX
    fixapp=$standalone.FIX
  else
    #fixapp=$standalone_filename.jar.FIX
    fixapp=$standalone.FIX
  fi
  #echo fixapp=$fixapp

  if [ ! -f $fixapp ];then
    echo cp $standalone $fixapp > /dev/stderr
    cp $standalone $fixapp
  fi

    #echo putlocaljars $fixapp lib
    jars=$(putlocaljars $fixapp $target $force_opt)
    #if [[ -z "$jars" ]];then
    #  echo rm -f $fixapp
    #  rm -f $fixapp
    #fi
    for j in $jars;do 
      echo "=> $j" > /dev/stderr
    done

  #else
  #  echo "$fixapp exists, means deployed lib done !" > /dev/stderr
  #fi

  echo $fixapp $standalone
}


#############################################
## main
#############################################
if [ $target ];then 
    apps=$(main_deploylib $target)
   ./rollback.sh -k 6 $workingdir 

   ##rollback done, replace standalone with .FIX version
   #fixapp=${apps[0]} standalone=${apps[1]}
   #echo mv $fixapp $standalone
   echo mv $apps
   mv $apps

   echo cleanup $standalone_ext
   cleanup $standalone_ext
fi


