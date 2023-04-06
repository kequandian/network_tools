#!/bin/sh
docker image rm zelejs/mysqlbackup:arm32v7

docker build -f Dockerfile.mysqlbackup.copy -t zelejs/mysqlbackup:arm32v7 .

## clean up
docker image rm zelejs/mysqlbackup:latest

## push
docker push zelejs/mysqlbackup:latest
