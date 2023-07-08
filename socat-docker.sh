#!/bin/sh
#echo socat listening on 0.0.0.0:2375 ...
#socat -d TCP-LISTEN:2375,reuseaddr,fork UNIX:/var/run/docker.sock
docker run -d --name socat --restart=always \
    -p 2376:2375 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    alpine/socat \
    tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

