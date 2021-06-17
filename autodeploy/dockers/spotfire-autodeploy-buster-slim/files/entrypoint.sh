#!/usr/bin/env bash

if [ -z "${SSH_PUB_KEY}" ] || [ -z "${SSH_PUB_KEY}" ]; then
  echo "ERROR: Missing $SSH_PRIV_KEY or $SSH_PUB_KEY"
  exit
#else
#  echo "OK"
fi

mkdir -p /home/spotfire/.ssh/ && \
  echo "$SSH_PRIV_KEY" > /home/spotfire/.ssh/id_rsa && \
  echo "$SSH_PUB_KEY" > /home/spotfire/.ssh/id_rsa.pub && \
  chmod 600 /home/spotfire/.ssh/id_rsa && \
  chmod 600 /home/spotfire/.ssh/id_rsa.pub

# just for testing
#ls -la /home/spotfire/.ssh/*

# pass arguments
make "$@"
