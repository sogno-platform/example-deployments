# PMU/Kafka/TimescaleDB Data Visualization Demo

This repository contains deployment instructions and corresponding configuration files for the SOGNO Platform.
The core platform is based on the SOGNO platform.
We assume you have a full-fleged or light-weight kubernetes cluster up and running. 
Please ensure you setup is in line with [this](https://sogno-platform.github.io/docs/getting-started/single-node/) base setup.

## Create Namespace
Create `demo` namespace where resources will be deployed
```bash
$ kubectl create namespace demo
```

## Container Registry credentials

This deployment requires an access to a container registry to pull and push Docker images. In order to do this, a secret with the registry credentials has to be created.

Modify `regcred-secret.yaml` with the appropriate credentials (the `data[.dockerconfigjson]` corresponds to the contents of `~/.docker/config.json` encoded in base64) and apply the secret manifest:
```bash
kubectl apply -f regcred-secret.yaml -n demo
```

## Visualization Stack

### Kafka/Strimzi Deployment

Deploy the Strimzi Cluster Operator
```bash
$ helm repo add strimzi https://strimzi.io/charts/
$ helm repo update
$ helm install strimzi strimzi/strimzi-kafka-operator -n demo
```

Deploy the Kafka Cluster
```bash
$ kubectl apply -f strimzi/strimzi-kafka-cluster.yaml -n demo
```

Wait for Cluster to be ready
```
$ kubectl wait kafka/strimzi-cluster -n demo --for=condition=Ready --timeout=300s
```

### Timescale Database

Add helm chart repo
```bash
$ helm repo add timescaledb 'https://raw.githubusercontent.com/timescale/timescaledb-kubernetes/master/charts/repo/'
```

Install helm chart
```bash
$ helm repo add timescaledb 'https://raw.githubusercontent.com/timescale/timescaledb-kubernetes/master/charts/repo/'
$ openssl req -x509 -sha256 -nodes -newkey rsa:4096 -days 3650 -subj "/CN=*.timescaledb.svc.cluster.local" -keyout tls.key -out tls.crt
$ kubectl create secret generic -n demo timescaledb-cluster-certificate --from-file=tls.crt=tls.crt --from-file=tls.key=tls.key
$ rm tls.crt tls.key
$ kubectl apply -f timescaledb/timescaledb-credentials-secret.yaml -n demo
$ helm install timescaledb-cluster timescaledb/timescaledb-single -n demo -f timescaledb/timescaledb-values.yaml
```

Directly execute a psql session on the master node
```bash
$ MASTERPOD="$(kubectl get pod -o name --namespace demo -l release=timescaledb-cluster)" 
$ kubectl exec -i --tty --namespace demo ${MASTERPOD} -- psql -U postgres
```

Create a database named kafka with user kafka and grant access
```sql
> CREATE DATABASE kafka;
> CREATE ROLE kafka WITH LOGIN SUPERUSER PASSWORD 'kafka';
> GRANT ALL PRIVILEGES ON DATABASE kafka TO kafka;
```

### Kafka Connect/Kafka Connector

Modify the container image registry URL at `kafka-connect/kafka-connect.yaml` and apply the Kafka Connect manifest
```bash
$ kubectl apply -f kafka-connect/kafka-connect.yaml -n demo
```

Apply the Kafka Sink Connector manifest
```bash
$ kubectl apply -f kafka-connect/kafka-sink-connector.yaml -n demo
```

### PMU Simulation
Modify the template at `pmu-dummy/template-configmap.yaml` if necessary and apply the configmap manifest
```bash
$ kubectl apply -f pmu-dummy/template-configmap.yaml -n demo
```

Modify the environment variables at `pmu-dummy/deployment.yaml` and apply the deployment manifest
```bash
$ kubectl apply -f pmu-dummy/deployment.yaml -n demo
```

### Kafka Streams

Modify the environment variables at `kafka-streams/kafka-streams-deployment.yaml` and apply the deployment manifest
```bash
$ kubectl apply -f kafka-streams/kafka-streams-deployment.yaml -n demo
```

### Grafana

Adjust the host url inside */visualization/grafana_values.yaml* for the Ingress component and install the helm repo
```bash
$ helm repo add grafana https://grafana.github.io/helm-charts
$ helm install grafana grafana/grafana -f visualization/grafana_values.yaml -n demo
```

Apply dashboard configmap
```bash
$ kubectl apply -f visualization/dashboard-configmap.yaml -n demo
```

Get admin password
```bash
$ kubectl get secret -n demo grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Access the url provided in the ingress component in a web browser to visualize the data