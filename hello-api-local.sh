
if [ -z $(ls $PWD/app/*.jar 2> /dev/null) ];then
   docker run --rm -v $PWD/app:/var/webapps zelejs/allin-web:hello-api cp /webapps/app.jar /var/webapps
fi

docker run --rm --name=hello-api -v $PWD/app:/webapps -p 8080:8080 zelejs/allin-web:hello-api
