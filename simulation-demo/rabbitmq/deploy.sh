#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR &> /dev/null

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
