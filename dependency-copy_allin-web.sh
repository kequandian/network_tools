usage(){
   echo "usage: dependency-copy.sh <groupId:artifact:version[:jar:classifier]> <ContainerID>"
   exit
}
if [ ! $@ ];then
   usage
fi
ARTIFACT=$1
CONTAINER=$2
if [ ! $CONTAINER ];then 
   usage
fi

curdir=${PWD}
dir=$(dirname $0)
cd $dir/repo
docker run --rm -v ${PWD}:/var/repo zelejs/allin-web:dependency-copy "$ARTIFACT"
ls -l *.jar
cd $curdir

## copy to artifact lib
cd  dummy
## deploiy repo/*.jar to 
CONTAINER=$CONTAINER ./dummy-deploy.sh
