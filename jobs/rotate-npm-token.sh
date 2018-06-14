#!/bin/bash

set -o errexit

if [ -z ${NPM_TOKEN} ]; then
  echo "Environment variable NPM_TOKEN unset; value: ${NPM_TOKEN:-undefined}"
  exit 1
fi

npm token list
