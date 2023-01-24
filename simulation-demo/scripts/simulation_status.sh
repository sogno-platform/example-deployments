#!/bin/bash
set -o errexit
set -o nounset
function error_func() {
    echo "Error detected at line no. $1"
}
trap 'error_func $LINENO' ERR

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
pushd $SCRIPT_DIR &> /dev/null

echo "------------------------ status --------------------------"

function start_api_pf() {
    $(pwd)/api_port_forward.sh
    sleep 3
}

# Start port forwarding service if it doesn't already exist
API_PF_EXISTS=$(ps -C "kubectl" -f --no-headers | grep "dpsim-api" || true)
[[ -z "$API_PF_EXISTS" ]] && start_api_pf

SIMULATION_ID=$1

API_REQUEST_RESULT=$(curl --silent -X 'GET' "http://127.0.0.1:8000/simulation/$SIMULATION_ID" || true)
echo "API_REQUEST_RESULT: " $API_REQUEST_RESULT
READY=$(echo $API_REQUEST_RESULT | jq -r .results_data | jq .ready | tr -d '"')
echo "Ready?: " $READY

if [ "x$READY" == "xtrue" ]
then
    SIMULATION_ID=$(echo $API_REQUEST_RESULT | jq .simulation_id | tr -d '"')
    API_DOWNLOAD_BODY=$(curl --silent -X 'GET' "http://127.0.0.1:8000/simulation/$SIMULATION_ID" )
    API_DOWNLOAD_RESULT=$(echo $API_DOWNLOAD_BODY | jq '.results_data | fromjson')
    RESULTS_BASE64=$(echo $API_DOWNLOAD_RESULT | jq -r .content)
    RESULTS=$(echo $RESULTS_BASE64 | base64 -d)
    echo Results: $RESULTS
else
    echo "Still not ready."
fi

echo "END"
