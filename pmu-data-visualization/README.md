# PMU Data Visualization 

This example contains deployment instructions and corresponding configuration files for a PMU data visualization stack.
We assume you have a full-fleged or light-weight kubernetes cluster up and running. 
Please ensure your setup is in line with [this](https://sogno-platform.github.io/docs/getting-started/single-node/) base setup.
A more detailed description is available [here](https://sogno-platform.github.io/docs/).

*Please mind that this is an example deployment solely for development and demonstration purposes.
Do not use this exact deployment in production environments.*

## Databus

The databus is realized by a [RabbitMQ](https://www.rabbitmq.com/) broker with enabled MQTT support.

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm repo update
$ helm install -n sogno-datavis-demo --create-namespace -f databus/rabbitmq_values.yaml rabbitmq bitnami/rabbitmq
```

## Time Series Database

We use [InfluxDB](https://www.influxdata.com/products/influxdb/) as time series database to store all PMU measurements.
It can be installed from their official helm chart.

```bash
$ helm repo add influxdata https://influxdata.github.io/helm-charts
$ helm repo update
$ helm install influxdb influxdata/influxdb -n sogno-datavis-demo -f ts-database/influxdb-helm-values.yaml
```

Find the pod

```bash
$ kubectl --namespace sogno-datavis-demo get pods
```

Login to the pod

```bash
$ kubectl --namespace sogno-datavis-demo exec -i -t [pod name] /bin/sh
```


Run influxdb CLI

```bash
$ influx
```

Create database and user telegraf and grant access

```sql
> CREATE DATABASE telegraf
> SHOW Databases
> CREATE USER telegraf WITH PASSWORD 'telegraf'
> GRANT ALL ON "telegraf" TO "telegraf"
```

## TS-DB Adapter
 Due to limitations with nested `json`, we use a [patched](https://hub.docker.com/r/rwthacs/telegraf-sogno) version of [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) as a database adapter.
 This version is compatible with the current SOGNO PMU data specification.

But first, we create a configmap for our telegraf instance. 
Afterward we simply deploy the database adapter in conjunction with the created config map.

```bash
$ kubectl apply -k ts-adapter/
$ kubectl apply -f ts-adapter/telegraf-deployment.yaml
```

## Grafana

Install [Grafana](https://grafana.com/) from the official helm chart

```bash
$ helm install grafana stable/grafana -f visualization/grafana_values.yaml
```

Obtain the admin password for the web UI

```bash
$ kubectl get secret -n sogno-datavis-demo grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
