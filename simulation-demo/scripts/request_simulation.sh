#!/bin/bash
set -o errexit
set -o nounset
FILE_UPLOAD_RESULT=""
LOAD_PROFILE_UPLOAD_RESULT=""
API_REQUEST_RESULT=""

function error_func() {
    echo "Error detected at line no. $1"
    echo "File upload: $FILE_UPLOAD_RESULT"
    echo "Load profile: $LOAD_PROFILE_UPLOAD_RESULT"
    echo "Api request:  $API_REQUEST_RESULT"
}
trap 'error_func $LINENO' ERR

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
pushd $SCRIPT_DIR &> /dev/null

if [ ! -e Rootnet_FULL_NE_06J16h.zip ]
then
    echo "I don't have a model to upload."
    echo "You need to download the model files from the data_for_simulation_demo"
    echo "branch of https://github.com/sogno-platform/example-deployments"
    exit 1
fi

# Start port forwarding services if they don't already exist
API_PF_EXISTS=$(ps -C "kubectl" -f --no-headers | grep "dpsim-api" || true)
[ -z "$API_PF_EXISTS" ] && $(pwd)/api_port_forward.sh
FILE_PF_EXISTS=$(ps -C "kubectl" -f --no-headers | grep "sogno-file-service" || true)
[ -z "$FILE_PF_EXISTS" ] && $(pwd)/file_port_forward.sh

# Give port forwarding services time to start
sleep 3

echo "------------------------ file service -------------------------"

FILE_UPLOAD_RESULT=$(curl -X 'POST' 'http://127.0.0.1:8080/api/files' \
                          --silent \
                          -H 'accept: application/json' \
                          -H 'Content-Type: multipart/form-data' \
                          -F 'file=@Rootnet_FULL_NE_06J16h.zip;type=application/zip')
echo "result of model file upload: $FILE_UPLOAD_RESULT"
FILE_ID=$(echo $FILE_UPLOAD_RESULT | jq .data.fileID)
echo "file id on file service: $FILE_ID"

#LOAD_PROFILE_UPLOAD_RESULT=$(curl -X 'POST' 'http://127.0.0.1:8080/api/files' \
#                          --silent \
#                          -H 'accept: application/json' \
#                          -H 'Content-Type: multipart/form-data' \
#                          -F 'file=@loadprofiles.zip;type=application/zip')
#echo "result of load profile data upload: $LOAD_PROFILE_UPLOAD_RESULT"
#LOAD_PROFILE_ID=$(echo $LOAD_PROFILE_UPLOAD_RESULT | jq .data.fileID)
#echo "load profile data id on file service: $LOAD_PROFILE_ID"
LOAD_PROFILE_ID='"None"' # Remove this line and uncomment the above to send the load profile data
                         # assuming you have downloaded it from the data_for_simulation_demo branch

if [ "x$FILE_ID" = "xnull" ]
then
    echo "Unable to upload model. Please check file exists, file service is running, port forward service is running, your (minikube) file system is not 100% full."
    exit 1
fi

if [ "x$LOAD_PROFILE_ID" = "xnull" ]
then
    echo "Unable to upload model. Please check file exists, file service is running, port forward service is running."
    exit 1
fi

echo "------------------------ api service --------------------------"

# Give time for file api to accept files
sleep 3

API_REQUEST_RESULT=$(curl -X 'POST' \
  'http://localhost:8000/simulation' \
  --silent \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "{
    \"simulation_type\": \"Powerflow\",
    \"model_id\":        $FILE_ID,
    \"load_profile_id\": $LOAD_PROFILE_ID,
    \"domain\":          \"SP\",
    \"solver\":          \"NRP\",
    \"timestep\":        1,
    \"finaltime\":       60
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
    echo "Simulation results are not ready. You can request them later with ./scripts/simulation_status.sh $SIMULATION_ID"
fi

echo "END"
