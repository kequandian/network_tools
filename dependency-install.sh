#!/usr/bin/env bash
# -Dmdep.useBaseVersion=true
# mdep.useBaseVersion=true will remove timestamps from snapshot builds.

## solution:
## https://maven.apache.org/guides/mini/guide-3rd-party-jars-remote.html
## -DgeneratePom=false

REPO='http://git.smallsaas.cn:8081/repository/internal'
REPO_ID='archiva-internal'
REPO2='http://repo.dev.smallsaas.cn:8082/repository/internal'
REPO2_ID='archiva-internal-dev'

usage() {
	cat <<- EOF
    Usage: dependency-install [OPTIONS] <target>
    e.g.  dependency-install target/webjar-RELEASE.jar

    OPTIONS:
      -h --help        --print usage
      -r --repo        --deploy to the standard repo [default]
      -R --REPO        --deploy to the DEV repo  
	EOF
	exit
}


## check options
repo_id=$9
repo_url=$9
for opt in $@;do
   if [[ $opt = '-h' || $opt = '--help' ]];then 
      usage
   elif [[ $opt = '-r' || $opt = '--repo' ]];then
      repo_url=$REPO
      repo_id=$REPO_ID
   elif [[ $opt = '-R' || $opt = '--REPO' ]];then
      repo_url=$REPO2
      repo_id=$REPO2_ID
   fi
done
if [ ! $repo_url ];then 
   repo_url=$REPO
   repo_id=$REPO_ID
fi

parse_artifact(){
   local artifact=$1   
   local artifactId
   local artifact_classifier
   local artifact_version

   artifact=${artifact%.jar}
   artifact=${artifact##*/}

   artifactId=${artifact%-*}
   # echo artifactId= $artifactId
   artifact_classifier=${artifact##*-}
   # echo artifact_classifier= $artifact_classifier
   artifact_version=${artifactId##*-}
   # echo artifact_version= $artifact_version
   ########### comment out
   # echo artifact_classifier= $artifact_classifier
   # artifact_version_classifier=${artifact#*-}
   # echo artifact_version_classifier= $artifact_version_classifier
   # artifact_classifier=${artifact_version_classifier##*-}
   # echo artifact_classifier= $artifact_classifier
   ############
   if [[ $artifact_classifier = [0-9.]* ]];then 
      artifact_version=$artifact_classifier
      unset artifact_classifier
   fi
   if [[ $artifact_version = [0-9.]* ]];then 
      artifactId=${artifactId%-*}
   fi
   # echo artifactId= $artifactId

   ## get version
   if [ ! $artifact_version ];then
       artifact_version=${artifact_version_classifier%-*}
   fi
   echo $artifactId  $artifact_version $artifact_classifier
}

# debug parse
# parse_artifact 'build/libs/mysql-test-1.0-all.jar'

install_artifact(){
      artifact=$1
      artifact=${artifact%$'\n'}

   local groupId
   local artifactId
   local version
   local classifier

   # echo "jar tf $artifact | grep pom.properties | grep com.tools" > /dev/stderr
   local entry=$(jar tf $artifact | grep pom.properties | grep com.tools)
   if [ -z "$entry" ];then
      # echo "jar tf $artifact | grep pom.properties | grep com.jfeat" > /dev/stderr
      entry=$(jar tf $artifact | grep pom.properties | grep com.jfeat)
   fi
   local entries=(${entry})
   if [ -z "$entry" ];then 
      echo no pom.properties entry found ! > /dev/stderr
      # artifactId=${artifact%.jar}
      # artifactId=${artifactId%-all}
      # artifactId=${artifactId%-RELEASE}
      parse_line=$(parse_artifact $artifact)
      parse_array=($parse_line)
      artifactId=${parse_array[0]}
      version=${parse_array[1]}
      classifier=${parse_array[2]}

   elif [[ ${#entries[@]} > 1 ]];then 
      echo multi pom.properties entries found, just get from artifact .. > /dev/stderr
      # artifactId=${artifact%.jar}
      # artifactId=${artifactId%-all}
      # artifactId=${artifactId%-RELEASE}
      parse_line=$(parse_artifact $artifact)
      parse_array=($parse_line)
      artifactId=${parse_array[0]}
      version=${parse_array[1]}
      classifier=${parse_array[2]}

   else
      # echo jar xf $artifact $entry
      jar xf $artifact $entry
      if [ ! -f "$entry" ];then 
         echo fail to get pom.properties
         exit
      fi
      local content=$(cat $entry)
      for line in $content;do
         line=${line%$'\n'}
         line=${line%$'\r'}
         line=${line%$'\t'}
         # echo line=$line

         if [[ $line = artifactId=* ]];then 
            artifactId=${line#artifactId=}
         elif [[ $line = version=* ]];then
            version=${line#version=}
         elif [[ $line = groupId=* ]];then 
            groupId=${line#*=}
            # groupId=${line%$'\r'}
            if [[ $groupId = com.tools* ]];then 
               groupId='com.tools'
            elif [[ $groupId = com.jfeat* ]];then 
               groupId='com.jfeat'
            fi
         fi
      done
   fi

   if [ ! $artifactId ];then 
      echo fail to get 'groupId:artifactId:version' > /dev/stderr
      exit
   fi

# artifact= build/libs/mysql-test-1.0-all.jar
# groupId=
# artifactId= mysql
# version= 1.0-all
# classifier=
   echo artifact= $artifact
   if [ ! $groupId ];then
      if [[ $artifact = build/libs/* ]];then
      groupId='com.tools'
      else
      groupId='com.jfeat'
      fi
   fi
   echo groupId= $groupId
   echo artifactId= $artifactId
   echo version= $version
   if [ ! $classifier ];then
      classifier=${artifact%.jar}
      classifier=${classifier##*-}
   fi
   echo classifier= $classifier
   echo

   #    mvn install:install-file -Dfile=./id-worker.jar -DgroupId=com.jfeat -DartifactId=id-worker -Dversion=1.0.0 -DrepositoryId=archiva-internal -Durl=http://git.smallsaas.cn:8081/repository/internal -DgeneratePom=false
   if [[ $groupId = 'com.tools' ]];then
   echo "mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -DgeneratePom=false -Dclassifier=$classifier" -DgroupId=com.tools -Dversion=1.0
   else
   echo "mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -DgeneratePom=false -Dclassifier=$classifier" -DgroupId=com.jfeat -Dversion=1.0
   fi

   if [ $classifier ];then
      if [[ $groupId = 'com.jfeat' ]];then
      mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -Dpackaging=jar -DgeneratePom=false -Dclassifier=$classifier -DgroupId=com.jfeat -Dversion=1.0 
      elif [[ $groupId = 'com.tools' ]];then
      mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -Dpackaging=jar -DgeneratePom=false -Dclassifier=$classifier -DgroupId=com.tools -Dversion=1.0 
      fi
   else 
      if [[ $groupId = 'com.jfeat' ]];then
      mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -Dpackaging=jar -DgeneratePom=false -DgroupId=com.jfeat -Dversion=1.0
      elif [[ $groupId = 'com.tools' ]];then
      mvn install:install-file -Dfile=./$artifact -DartifactId=$artifactId -DrepositoryId=$repo_id -Durl=$repo_url -Dpackaging=jar -DgeneratePom=false -DgroupId=com.tools -Dversion=1.0
      fi
   fi
}

## main
artifact=$1
if [ $artifact -a -f $artifact ];then 
   install_artifact $artifact
else
   artifact_ls=$(ls *.jar build/libs/*-all.jar 2> /dev/null)
   if [ -z "$artifact_ls" ];then 
      usage
   elif [ -f "$artifact_ls" ];then 
      install_artifact "$artifact_ls"
   else 
      ## means multi file
      for art in $artifact_ls;do
         echo $art
      done
   fi
fi