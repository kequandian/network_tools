#!/bin/sh
docker run -d  -v /var/run/docker.sock:/var/run/docker.sock --name socat -p 0.0.0.0:2375:2375 bobrik/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
