##### This is the expected output from start_demo.sh

```bash
Starting mosquitto
deployment.apps/mosquitto created
service/mosquitto created
configmap/mosquitto.config created

Starting rabbitmq
deployment.apps/rabbitmq created
service/rabbitmq created

Starting redis
NAME: redis
LAST DEPLOYED: Tue Jan 17 19:31:48 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: redis
CHART VERSION: 17.4.3
APP VERSION: 7.0.8
** Please be patient while the chart is being deployed **
Redis® can be accessed on the following DNS names from within your cluster:
    redis-master.default.svc.cluster.local for read/write operations (port 6379)
    redis-replicas.default.svc.cluster.local for read-only operations (port 6379)
To connect to your Redis® server:
1. Run a Redis® pod that you can use as a client:
   kubectl run --namespace default redis-client --restart='Never'  --image docker.io/bitnami/redis:7.0.8-debian-11-r0 --command -- sleep infinity
   Use the following command to attach to the pod:
   kubectl exec --tty -i redis-client \
   --namespace default -- bash
2. Connect using the Redis® CLI:
   redis-cli -h redis-master
   redis-cli -h redis-replicas
To connect to your database from outside the cluster execute the following commands:
    kubectl port-forward --namespace default svc/redis-master 6379:6379 &
    redis-cli -h 127.0.0.1 -p 6379

Starting minio
deployment.apps/minio created
service/minio created
configmap/aws-config created
Using default tag: latest
latest: Pulling from amazon/aws-cli
a803d5fd9f1b: Pull complete 
523f846b1a12: Pull complete 
88753ca84ec9: Pull complete 
a631c8695749: Pull complete 
04db5a5c926d: Pull complete 
Digest: sha256:db4ef958902a64ff3a0b5f73d014b6386c66adb2736161b4c809e58fc505904c
Status: Downloaded newer image for amazon/aws-cli:latest
docker.io/amazon/aws-cli:latest
Creating sogno-platform bucket
make_bucket: sogno-platform
pod "aws-cli" deleted

Starting file service
deployment.apps/sogno-file-service created
service/sogno-file-service created
configmap/aws-fs-config created

Starting dpsim api
NAME: dpsim-api
LAST DEPLOYED: Tue Jan 17 19:32:13 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services dpsim-api)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

Starting dpsim worker
NAME: dpsim-worker
LAST DEPLOYED: Tue Jan 17 19:32:14 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=dpsim-worker,app.kubernetes.io/instance=dpsim-worker" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```
