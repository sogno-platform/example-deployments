#!/bin/bash
set -o nounset
set -o errexit

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
pushd $SCRIPT_DIR &> /dev/null

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
helm install dpsim-api sogno/dpsim-api &&
echo "Starting dpsim worker" &&
helm install dpsim-worker sogno/dpsim-worker
