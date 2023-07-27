#!/bin/sh
echo socat listening on 0.0.0.0:2375 ...
socat -d TCP-LISTEN:2375,reuseaddr,fork UNIX:/var/run/docker.sock

