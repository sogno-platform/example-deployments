#!/bin/bash
set -o nounset
set -o errexit

export POD_NAME=$(kubectl get pods --namespace default -l "app=sogno-file-service" -o jsonpath="{.items[0].metadata.name}")
nohup kubectl --namespace default port-forward $POD_NAME 8080:8080 > file_nohup &
LAST_PROCESS=$!
echo $LAST_PROCESS
