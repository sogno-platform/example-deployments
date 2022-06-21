#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

kubectl delete deployment sogno-file-service
./deploy.sh
