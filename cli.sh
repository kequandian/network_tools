#!/bin/sh
export DEPLOY_OPT=deploy
docker-compose -f dummy.yml run --rm dummy bash
