## How to run the simulation demo

#### Set up the simulation environment

```bash
./scripts/start_demo.sh
```

This should produce the output in the file linked below. It is not included here because it is too long. Read the output carefully. If it produces a different output, something has gone wrong.

[Expected output from start_demo.sh](StartDemo.md)

```bash
$ kubectl get pods
```

This should produce similar output to the block below. Pay particular attention to the "READY" and "STATUS" columns.
They will tell you if everything is proceeding as planned.

```bash
NAME                                READY    STATUS     RESTARTS AGE
dpsim-api-5f64497c77-xbv2j          1/1      Running    0        81m
dpsim-worker-67745b846d-vphfz       1/1      Running    0        81m
minio-fdf94ddbf-bdkz7               1/1      Running    0        93m
mosquitto-68cd9f467b-k4tzs          1/1      Running    0        93m
rabbitmq-55985c79c4-gwclk           1/1      Running    0        93m
redis-master-0                      1/1      Running    0        93m
redis-replicas-0                    1/1      Running    0        93m
redis-replicas-1                    1/1      Running    0        92m
redis-replicas-2                    1/1      Running    0        92m
sogno-file-service-5987c95cc5-6rw66 1/1      Running    0        93m
```

#### The swagger UI

You can use the swagger UI to run a demo. If you don't know the parameters for an API it is a good way to improve your understanding.
If you just want to see a simulation being run, it is quicker to the scripts provided.
The swagger UI is described [here.](Swagger.md)

#### Running a simulation without the swagger UI

The next thing to do is request a simulation. This doest thou thus:

```bash
./scripts/request_simulation.sh
```

Hopefully you will see the following output:

```bash
------------------------ file service -------------------------
result of model file upload: {"data":{"fileID":"6c8957f2-089d-485e-98ee-7c75be20f66b","lastModified":"2023-01-17T15:34:31Z","url":"[http://minio:9000/sogno-platform/6c8957f2-089d-485e-98ee-7c75be20f66b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T153431Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=00ba7fd3a07b2ee6b1ed675bf95bdf6c98ae71c5a055a12899b5b1e6e8e6585f"}}](http://minio:9000/sogno-platform/6c8957f2-089d-485e-98ee-7c75be20f66b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T153431Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=00ba7fd3a07b2ee6b1ed675bf95bdf6c98ae71c5a055a12899b5b1e6e8e6585f"%7D%7D) file id on file service: "6c8957f2-089d-485e-98ee-7c75be20f66b"
------------------------ api service --------------------------
result of api request: {"error":"","load_profile_id":"None","model_id":"6c8957f2-089d-485e-98ee-7c75be20f66b","results_id":"57c91923-c2ed-46c0-a15a-3f8396771006","results_data":"","simulation_id":1,"simulation_type":"Powerflow","domain":"SP","solver":"NRP","timestep":1,"finaltime":60}
------------------------ results --------------------------
Ready?: false
Simulation results are not ready. You can request them later with ./scripts/simulation_status.sh 1
```

The simulation should take approximately one minute to run, because we have requested a finaltime of 60 seconds. So, returning to our work after one minute of calm reflection, we should be able to run the following:

```bash
$ kubectl logs dpsim-worker-67745b846d-vphfz
Configuring logging
[14:26:09.885 root info] Opening rabbitmq connection
[14:33:07.750 root info] Received a message: b'{"load_profile":"","model":{"type":"url-list","url":["[http://minio:9000/sogno-platform/e73766ef-ea70-4bdc-b5af-340117ba86a6?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T143307Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=58a97da295b0e8f861f7927175c11accc04aa2c864ef157ece4db8c51dae5cbb"]},"parameters":{"domain":"SP","duration":20,"executable":"SLEW_Shmem_CIGRE_MV_PowerFlow","finaltime":60,"name":"SLEW_Shmem_CIGRE_MV_PowerFlow","results_file":"0def788b-a2dd-4431-bce5-48022bfb517b","solver":"NRP","timestep":0.1}}'](http://minio:9000/sogno-platform/e73766ef-ea70-4bdc-b5af-340117ba86a6?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T143307Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=58a97da295b0e8f861f7927175c11accc04aa2c864ef157ece4db8c51dae5cbb"%5D%7D,"parameters":%7B"domain":"SP","duration":20,"executable":"SLEW_Shmem_CIGRE_MV_PowerFlow","finaltime":60,"name":"SLEW_Shmem_CIGRE_MV_PowerFlow","results_file":"0def788b-a2dd-4431-bce5-48022bfb517b","solver":"NRP","timestep":0.1%7D%7D') [14:33:07.759 root info] No load_profile in {}
[14:33:07.759 root info] Downloading file: [http://minio:9000/sogno-platform/e73766ef-ea70-4bdc-b5af-340117ba86a6?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T143307Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=58a97da295b0e8f861f7927175c11accc04aa2c864ef157ece4db8c51dae5cbb](http://minio:9000/sogno-platform/e73766ef-ea70-4bdc-b5af-340117ba86a6?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=SECRETUSER%2F20230117%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230117T143307Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=58a97da295b0e8f861f7927175c11accc04aa2c864ef157ece4db8c51dae5cbb) [14:33:07.772 root info] Content Disposition: filename=e73766ef-ea70-4bdc-b5af-340117ba86a6.zip
[14:33:07.773 root info] Downloaded models: ['e73766ef-ea70-4bdc-b5af-340117ba86a6.zip']
[14:33:07.773 root info] PARAMETERS: {'domain': 'SP', 'duration': 20, 'executable': 'SLEW_Shmem_CIGRE_MV_PowerFlow', 'finaltime': 60, 'name': 'SLEW_Shmem_CIGRE_MV_PowerFlow', 'results_file': '0def788b-a2dd-4431-bce5-48022bfb517b', 'solver': 'NRP', 'timestep': 0.1}
[14:33:07.776 root info] Unzipped files: ['/etc/config/model/Rootnet_FULL_NE_06J16h_SV.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_EQ.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_DI.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_TP.xml']
[14:33:07.776 root info] The status will be upated in file with id: 0def788b-a2dd-4431-bce5-48022bfb517b
[14:33:07.776 root info] Requested simulation config: {'load_profile_files': '', 'model_files': ['/etc/config/model/Rootnet_FULL_NE_06J16h_SV.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_EQ.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_DI.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_TP.xml'], 'results_file_id': '0def788b-a2dd-4431-bce5-48022bfb517b', 'domain': 'SP', 'solver': 'NRP', 'timestep': 0.1, 'finaltime': 60}
Warning: could not assign attribute with name: cim:NameType.name and value: description
Warning: could not assign attribute with name: cim:Name.name and value: NETWORK-FEEDER:
Warning: could not assign attribute with name: cim:Name.name and value: Ratings
Warning: could not assign class of unrecognised type cim:Name.NameType.
Warning: could not assign class of unrecognised type cim:Name.IdentifiedObject.
CIMContentHandler: Note: 0 out of 778 tasks remain unresolved!
[14:33:07.827 root info] Starting dpsim with model files: ['/etc/config/model/Rootnet_FULL_NE_06J16h_SV.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_EQ.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_DI.xml', '/etc/config/model/Rootnet_FULL_NE_06J16h_TP.xml']
[14:33:07.827 root info] Starting dpsim with load profile files: 
[14:33:07.828 root info] Simulation starting
[14:33:07.836330 CIGRE_MV_PF_Solver warning] Unable to get base voltage at N0
[14:33:07.836694 CIGRE_MV info] Scheduling tasks.
[14:33:07.836976 CIGRE_MV info] Scheduling done.
[14:33:07.836993 CIGRE_MV info] Opening interfaces.
[14:33:07.837006 CIGRE_MV info] Start synchronization with remotes on interfaces
[14:33:07.837024 CIGRE_MV info] Synchronized simulation start with remotes
[14:33:07.837049 CIGRE_MV info] Starting simulation at 2023-01-17 14:33:08 (delta_T = 0 seconds)
[14:33:08.831016 CIGRE_MV info] Simulation started.
[14:34:08.729340 CIGRE_MV info] Simulation finished.
[14:34:08.729 root info] Simulation complete, uploading results
[14:34:08.761 root info] Uploaded results to fileID: 0def788b-a2dd-4431-bce5-48022bfb517b
```

```bash
./simulation_status.sh 1
```

Then you should see the results of a dpsim simulation. It will look a little bit like the text in the box below. Except the lines won't be truncated to 180 characters, like they are here.

```bash
------------------------ status --------------------------
API_REQUEST_RESULT:  {"error":"","load_profile_id":"None","model_id":"845cf6bd-3cf9-422e-b7ed-15558c79b7ed","results_id":"473b80e6-7aeb-4632-a5a6-aa42fb9ced70","results_data":"{\"ready\":\"true\", \"content\":\"ICAgICAgICAgIHRpbWUsICAgICAgIE4wLnYuaW0sICAgICAgIE4wLnYucmUsICAgICAgIE4xLnYuaW0sICAgICAgIE4xLnYucmUsICAgICAgTjEwLnYuaW0sICAgICAgTjEwLnYucmUsICAgICAgTjExLnYuaW0sICAgICAgTjExLnYucmUsICAgICAgTjEyLnYuaW0sICAgICAgTjEyLnYucmUsICAgICAgTjEzLnYuaW0sICAgICAgTjEzLnYucmUsICAgICAgTjE0LnYuaW0sICAgICAgTjE0LnYucmUsICAgICAgIE4yLnYuaW0sICAgICAgIE4yLnYucmUsICAgICAgIE4zLnYuaW0sICAgICAgIE4zLnYucmUsICAgICAgIE40LnYuaW0sICAgICAgIE40LnYucmUsICAgICAgIE41LnYuaW0sICAgICAgIE41LnYucmUsICAgICAgIE42LnYuaW0sICAgICAgIE42LnYucmUsICAgICAgIE43LnYuaW0sICAgICAgIE43LnYucmUsICAgICAgIE44LnYuaW0sICAgICAgIE44LnYucmUsICAgICAgI
Ready?:  true
Results: time, N0.v.im, N0.v.re, N1.v.im, N1.v.re, N10.v.im, N10.v.re, N11.v.im, N11.v.re, N12.v.im, N12.v.re, N13.v.im, N13.v.re, N14.v.im, N14.v.re, N2.v.im, N2.v.re, N3.v.im, N3.v.re, N4.v.im, N4.v.re, N5.v.im, N5.v.re, N6.v.im, N6.v.re, N7.v.im, N7.v.re, N8.v.im, N8.v.re, N9.v.im, N9.v.re 0.000000e+00, 0.000000, 110000.000000, -2338.351339, 19068.762206, -3187.835024, 17483.587198, -3190.674762, 17478.863890, -1972.502176, 19286.859895, -1980.253890, 19185.668663, -1984.719913, 19127.491955, -2638.294629, 18525.446285, -3099.877354, 17664.840239, -3127.551786, 17620.482700, -3146.533250, 17590.038590, -3168.937450, 17554.002105, -3163.721634, 17529.451194, -3161.322145, 17535.918766, -3170.854080, 17513.316080 1.000000e-01, 0.000000, 110000.000000, -2338.351339, 19068.762206, -3187.835
END
```
