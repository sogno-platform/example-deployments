# Pyvolt DPsim Demo

Ensure the SOGNO Helm Chart Repo is setup or add it:

```bash
helm repo add sogno https://sogno-platform.github.io/helm-charts
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

## DPsim Simulation

```bash
helm install dpsim-demo sogno/dpsim-demo
```

## State-Estimation
```bash
helm install pyvolt-demo sogno/pyvolt-service -f state-estimation/se_values.yaml
```
