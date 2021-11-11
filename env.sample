#!/usr/bin/env bash
sourcing(){
  tmp=$(mktemp)
  echo "export DUMMY_CONTAINER=${CONTAINER}" > /$tmp
  source /$tmp
  rm -f /$tmp
}


CONTAINER=biliya-api sourcing

echo $DUMMY_CONTAINER
