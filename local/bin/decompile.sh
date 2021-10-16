#!/usr/bin/env bash
## deploy the  .class files from classes dir to the standalone jar
# declare -A hashmap
# hashmap[key]="value"
# hashmap[key2]="value2"
# echo hashmap has ${#hashmap[@]} elements
# for key in ${!hashmap[@]}; do echo $key; done
# for value in ${hashmap[@]}; do echo $value; done

opt=$1

## put one .class file to .jar file
putclasstojar(){
   javaclass=$1
   jar=$2

   # only .class
   clsext=${javaclass##*.}
   if [ ! $clsext = 'class' ];then
      exit
   fi

   ## main ##
   classname=$(basename $javaclass)
   # echo ...$classname
   classok=$("$JAR_BIN" tf $targetjar | grep $classname)
   if [ $classok ];then
      ## update lib
      classdir=$(dirname $classok)
      if [ ! -d $classdir ];then
         echo mkdir -p $classdir > /dev/stderr
         mkdir -p $classdir
      fi

      # core
      if [ $opt = debug ];then
         echo cp $javaclass $classdir > /dev/stderr
         cp $javaclass $classdir
      else 
         echo mv $javaclass $classdir > /dev/stderr
         mv $javaclass $classdir
      fi
      echo jar 0uf $targetjar $classok > /dev/stderr
      "$JAR_BIN" 0uf $targetjar $classok

      echo rm -r $classok > /dev/stderr
      rm -f $classok

      echo $classok
   fi
}


## start scripts

JAR_BIN=$(which jar)
JAVA_BIN=$(which java)

get_javaclass_hash_line_on_index_file(){
   local input=$1
   local class=$2

   if [ ! -f $input ];then
     echo $input not exists ! > /dev/stderr
     exit
   fi

   declare -A map

   lines=$(cat $input)
   for line in $lines;do
      # echo ... $line
      key=${line%%,*} value=${line#*,}
      map[$key]=$value
#      echo key=$key value=${map[$key]}
   done

   # echo key=$class  ${map[$class]}
   echo ${map[$class]}
   
   # map[Sunday]="星期天"
   # map[Monday]="星期一"
   # for key in ${!map[@]};do
   #    value=${map[$key]}
   #    echo $key, $value
   # done
}

put_classes_to_jar_on_indexes(){
   classesroot=$1
   indexesroot=$2
   libroot=$3

   for javaclass in $(ls $classesroot/*.class);do
      javaclassname=$(basename $javaclass)

      ## get the first letter of javaclass
      firstletter=${javaclassname::1}  ##first letter
      firstletter=${firstletter,,}
      indexinput="$indexesroot/$firstletter"

      #jarindex=com/jfeat/common/PcdModelMapping.class,pcd-domain-2.3.0.jar
      classindex=$(get_javaclass_hash_line_on_index_file $indexinput $javaclassname)
      entry=${classindex%%,*} jar=${classindex##*,}

      entrypath=$classesroot/$(dirname $entry)
      if [ ! -d $entrypath ];then
         mkdir -p $entrypath
      fi
      if [ $opt = debug ];then
        echo cp $javaclass $entrypath
        cp $javaclass $entrypath
      else
        echo mv $javaclass $entrypath
        mv $javaclass $entrypath
      fi
      #echo entry=$entry, entrypath=$entrypath, javaclass=$javaclass, jar=$jar

      ## get jar from standalone jar
      ## how about jar is root jar?
      local targetjar
      if [ ! -f $jar ];then
        libjar=$libroot/$jar

        if [ ! -f $libjar ];then
           jarfirstletter=${jar::1}  ##first letter
           jarindexinput="$indexesroot/$jarfirstletter"
           jarindex=$(get_javaclass_hash_line_on_index_file $jarindexinput $jar)

           jarentry=${jarindex%%,*} rootjar=${jarindex##*,}
           echo "jar xf $rootjar $jarentry" > /dev/stderr
           "$JAR_BIN" xf $rootjar $jarentry

          if [ $opt = debug ];then
            echo cp $jarentry $libjar > /dev/stderr
            cp $jarentry $libjar
          else
            echo mv $jarentry $libjar > /dev/stderr
            mv $jarentry $libjar
          fi
        fi

        ## check again
        if [ ! -f $libjar ];then
          echo $libjar not found! > /dev/stderr
          exit
        fi

        ## get the final
        targetjar=$libjar
      else
        targetjar=$jar
      fi

      echo "jar 0uf $targetjar -C $classesroot $entry" > /dev/stderr
      "$JAR_BIN" 0uf $targetjar -C $classesroot $entry
   done
}

## clean up
cleanup() {
  if [ -d BOOT-INF ];then
    rm -rf BOOT-INF/
  fi
  if [ -d WEB-INF ];then
    rm -rf WEB-INF/
  fi
}

## main
if [ -z $(ls classes/*.class 2>/dev/null) ];then
   echo 'no .class to deploy !' >/dev/stderr
   exit
fi

if [ -z $(ls indexes/* 2>/dev/null) ];then
   echo 'no indexes, skip deploy !' >/dev/stderr
   exit
fi

## main
   # classesroot=$1
   # indexesroot=$2
   # libroot=$3
echo put_classes_to_jar_on_indexes classes indexes lib
put_classes_to_jar_on_indexes classes indexes lib

cleanup