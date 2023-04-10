docker run --name=hello-api \
   -e TZ='Asia/Shanghai' \
   -v /etc/localtime:/etc/localtime:ro  \
   -p 8080:8080 \
   zelejs/allin-web:hello-api
