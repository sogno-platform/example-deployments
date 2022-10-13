#!/bin/bash
set -o nounset
set -o errexit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

minikube ssh docker pull 192.168.49.2:5000/dpsim:worker

echo "Starting mosquitto"
../mosquitto/deploy.sh &&
echo "Starting rabbitmq"
../rabbitmq/deploy.sh &&
echo "Starting redis" &&
../redis/deploy.sh &&
echo "Starting minio" &&
../minio/deploy.sh &&
echo "Starting file service" &&
../file-service/deploy.sh &&
echo "Starting dpsim api" &&
helm install dpsim-api sogno/dpsim-api --values=../dpsim-api/values.yaml &&
echo "Starting dpsim worker" &&
helm install dpsim-worker sogno/dpsim-worker --values=../dpsim-worker/values.yaml
