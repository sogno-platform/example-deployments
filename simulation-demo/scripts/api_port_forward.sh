#!/bin/bash
set -o nounset
set -o errexit

export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=dpsim-api" -o jsonpath="{.items[0].metadata.name}")
nohup kubectl --namespace default port-forward $POD_NAME 8000:8000 > api_nohup &
LAST_PROCESS=$!
echo $LAST_PROCESS
