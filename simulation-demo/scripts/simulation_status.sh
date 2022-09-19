#!/bin/bash
set -o errexit
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

echo "------------------------ status --------------------------"

API_PORT_FORWARD_PID=$($(pwd)/api_port_forward.sh)
sleep 3
SIMULATION_ID=$1

API_REQUEST_RESULT=$(curl --silent -X 'GET' "http://127.0.0.1:8000/simulation/$SIMULATION_ID" )
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

echo "------------------------ cleanup --------------------------"

kill -9 $API_PORT_FORWARD_PID || true
REMAINING_PORT_FORWARD_COMMANDS=$(ps -C "kubectl --namespace default port-forward" -f --no-headers) || true
if [ "x$REMAINING_PORT_FORWARD_COMMANDS" != "x" ]
then
    echo -e "\nPORT FORWARD PIDS STILL ALIVE: "
    echo $REMAINING_PORT_FORWARD_COMMANDS
    REMAINING_PF_PIDS=$(ps -C "kubectl --namespace default port-forward" -o pid= | tr '\n' ' ')
    echo "Clean up with: kill $REMAINING_PF_PIDS if you know this is ok"
else
    echo "All port forward processes have ended."
fi

echo "END"
