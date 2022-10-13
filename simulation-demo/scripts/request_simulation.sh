#!/bin/bash
set -o errexit
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

echo "------------------------ file service -------------------------"

FILE_PORT_FORWARD_PID=$($(pwd)/file_port_forward.sh)
echo "file service port forward pid: $FILE_PORT_FORWARD_PID"
sleep 3
FILE_UPLOAD_RESULT=$(curl -X 'POST' 'http://127.0.0.1:8080/api/files' \
                          --silent \
                          -H 'accept: application/json' \
                          -H 'Content-Type: multipart/form-data' \
                          -F 'file=@Rootnet_FULL_NE_06J16h.zip;type=application/zip')
echo "result of file upload: $FILE_UPLOAD_RESULT"
FILE_ID=$(echo $FILE_UPLOAD_RESULT | jq .data.fileID)
echo "file id on file service: $FILE_ID"

echo "------------------------ api service --------------------------"

API_PORT_FORWARD_PID=$($(pwd)/api_port_forward.sh)
echo "api port forward pid: $API_PORT_FORWARD_PID"
sleep 3
API_REQUEST_RESULT=$(curl -X 'POST' \
  'http://localhost:8000/simulation' \
  --silent \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "{
    \"simulation_type\": \"Powerflow\",
    \"model_id\":        $FILE_ID,
    \"load_profile_id\": \"1\",
    \"domain\":          \"SP\",
    \"solver\":          \"NRP\",
    \"timestep\":        1,
    \"finaltime\":       120
  }")

echo "result of api request: " $API_REQUEST_RESULT

echo "------------------------ results --------------------------"

sleep 2

SIMULATION_ID=$(echo $API_REQUEST_RESULT | jq .simulation_id | tr -d '"')
SECOND_API_REQUEST_RESULT=$(curl --silent -X 'GET' "http://127.0.0.1:8000/simulation/$SIMULATION_ID" )
READY=$(echo $SECOND_API_REQUEST_RESULT | jq -r .results_data | jq .ready | tr -d '"')
echo "Ready?: " $READY

if [ "x$READY" == "xtrue" ]
then
    API_DOWNLOAD_RESULT=$(echo $SECOND_API_REQUEST_RESULT | jq '.results_data | fromjson')
    RESULTS_BASE64=$(echo $API_DOWNLOAD_RESULT | jq -r .content)
    RESULTS=$(echo $RESULTS_BASE64 | base64 -d)
    echo Results: $RESULTS
else
    echo "Simulation results are not ready. You can request them later with ./simulation_status.sh $SIMULATION_ID"
fi

echo "------------------------ cleanup --------------------------"

kill -9 $API_PORT_FORWARD_PID || true
kill -9 $FILE_PORT_FORWARD_PID || true
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
