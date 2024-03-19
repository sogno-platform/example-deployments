# from urllib import request
from io import BufferedReader, StringIO
import time
import requests
from os import getenv
import json
import base64
import pandas as pd

file_service_url_base = f"http://{getenv('FILESERVICE_HOST','localhost')}:{int(getenv('FILESERVICE_PORT',32113))}/api"
dpsim_url_base = f"http://{getenv('DPSIM_HOST','localhost')}:{int(getenv('DPSIM_PORT',32348))}"


def upload_cim(cim_file: BufferedReader) -> str:
    resp = requests.post(
        url=file_service_url_base + "/files",
        files={"file": cim_file, "type": "application/x-zip-compressed"},
        headers={
            "accept": "application/json",
        },
    )
    if not (resp.ok):
        print(resp.text)
        return None
    return resp.json()["data"]["fileID"]

def upload_loadprofile(load_profile_file: BufferedReader) -> str:
    resp = requests.post(
        url=file_service_url_base + "/files",
        files={"file": load_profile_file, "type": "application/x-zip-compressed"},
        headers={
            "accept": "application/json",
        },
    )
    if not (resp.ok):
        print(resp.text)
        return None
    return resp.json()["data"]["fileID"]

def post_dpsim(cim_id: str, lp_id:str) -> str:
    simulation_body = {
        "simulation_type": "Powerflow",
        "model_id": cim_id,
        "load_profile_id": lp_id,
        "domain": "SP",
        "solver": "NRP",
        "timestep": 1,
        "finaltime": 60,
    }
    headers = {"accept": "application/json"}
    response = requests.post(
        url=dpsim_url_base + "/simulation", headers=headers, json=simulation_body
    )
    if not response.ok:
        print(response.text)
        return None
    return response.json()["simulation_id"]


def get_dpsim(simulation_id: str) -> str:
    headers = {"accept": "application/json"}
    result = {"ready": "false"}
    while result["ready"] == "false":
        response = requests.get(
            url=f"{dpsim_url_base}/simulation/{simulation_id}", headers=headers
        )
        if not response.ok:
            print(response.text)
            return None
        result = json.loads(response.json()["results_data"])
        print("result not ready ...")
        time.sleep(1)
    print(result["content"])
    return base64.b64decode(result["content"]).decode("utf-8") # subject to change of the nedpoint


def main():
    with open("../cim_data/Rootnet_FULL_NE_06J16h.zip", "rb") as cim_file:
        cim_id = upload_cim(cim_file)
    print(f"fileID of uploaded CIM file: {cim_id}")
    with open("../cim_data/load_profile_flat.zip", "rb") as loadprofile_file:
        lp_id = upload_loadprofile(loadprofile_file) 
    print(f"fileID of uploaded load profile file: {cim_id}")               
    simulation_id = post_dpsim(cim_id, lp_id)                          
    print(f"simulationID of the started simulation: {simulation_id}")
    result = get_dpsim(simulation_id)
    # print(result)
    df = pd.read_csv(StringIO(result), sep=",")
    print(df)


if __name__ == "__main__":
    main()
