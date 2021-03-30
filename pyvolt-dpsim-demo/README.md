# Pyvolt DPsim Demo

Ensure that the following Helm Chart Repos are set up or add them locally:

```bash
helm repo add sogno https://sogno-platform.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add influxdata https://influxdata.github.io/helm-charts

```

## Databus

```bash
helm install rabbitmq bitnami/rabbitmq -f databus/rabbitmq_values.yaml
```

## Database

```bash
helm install influxdb influxdata/influxdb -f database/influxdb-helm-values.yaml
```

## Database Adapter

```bash
helm install telegraf influxdata/telegraf -f ts-adapter/telegraf-values.yaml
```

## Visualization

Please check the grafana_values.yaml file and set required fields.

```bash
helm install grafana grafana/grafana -f visualization/grafana_values.yaml
kubectl apply -f visualization/dashboard-configmap.yaml
```
The configmap contains a demo dashboard and should automatically be recognized by the grafana instance.

## CIM Editor Pintura

The following installation will deploy a Pintura instance that is available at the nodePort specified in the pintura_values.yaml file. 
Per defautl at port 31234.

```bash
helm install pintura sogno/pintura -f cim-editor/pintura_values.yaml 
```
## DPsim Simulation

```bash
helm install dpsim-demo sogno/dpsim-demo
```

## State-Estimation
```bash
helm install pyvolt-demo sogno/pyvolt-service -f state-estimation/se_values.yaml
```
