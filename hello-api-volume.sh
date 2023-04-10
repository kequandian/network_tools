#!/bin/sh
## used to run hello-api with local api to /webapps
if [ -z $(ls $PWD/app/*.jar 2> /dev/null) ];then
   docker run --rm -v $PWD/app:/var/webapps zelejs/allin-web:hello-api cp /webapps/app.jar /var/webapps
fi

docker run --name=hello-api \
   -e TZ='Asia/Shanghai' \
   -v /etc/localtime:/etc/localtime:ro  \
   -v $PWD/app:/webapps \
   -p 8080:8080 \
   zelejs/allin-web:hello-api
