#!/bin/bash

namespace=demo

kubectl create namespace $namespace

kubectl apply -f regcred-secret.yaml -n $namespace

# Strimzi
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi strimzi/strimzi-kafka-operator -n $namespace
kubectl apply -f strimzi/strimzi-kafka-cluster.yaml -n $namespace
kubectl wait kafka/strimzi-cluster -n $namespace --for=condition=Ready --timeout=300s

# Timescale
helm repo add timescaledb 'https://raw.githubusercontent.com/timescale/timescaledb-kubernetes/master/charts/repo/'
openssl req -x509 -sha256 -nodes -newkey rsa:4096 -days 3650 -subj "/CN=*.timescaledb.svc.cluster.local" -keyout tls.key -out tls.crt
kubectl create secret generic -n $namespace timescaledb-cluster-certificate --from-file=tls.crt=tls.crt --from-file=tls.key=tls.key
rm tls.crt tls.key
kubectl apply -f timescaledb/timescaledb-credentials-secret.yaml -n $namespace
helm install timescaledb-cluster timescaledb/timescaledb-single -n $namespace -f timescaledb/timescaledb-values.yaml
kubectl wait pod/timescaledb-cluster-0 -n $namespace --for=condition=Ready --timeout=60s
kubectl exec timescaledb-cluster-0 -n $namespace -- psql -U postgres -c 'CREATE DATABASE kafka;'
kubectl exec timescaledb-cluster-0 -n $namespace -- psql -U postgres -c "CREATE ROLE kafka WITH LOGIN SUPERUSER PASSWORD 'kafka';"
kubectl exec timescaledb-cluster-0 -n $namespace -- psql -U postgres -c 'GRANT ALL PRIVILEGES ON DATABASE kafka TO kafka;'

# Kafka Connect
kubectl apply -f kafka-connect/kafka-connect.yaml -n $namespace

# Kafka Connector
kubectl apply -f kafka-connect/kafka-sink-connector.yaml -n $namespace

# PMU-dummy
kubectl apply -f pmu-dummy/template-configmap.yaml -n $namespace
kubectl apply -f pmu-dummy/deployment.yaml -n $namespace

# Kafka Streams
kubectl apply -f kafka-streams/kafka-streams-deployment.yaml -n $namespace

# Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -f visualization/grafana_values.yaml -n $namespace
kubectl apply -f visualization/dashboard-configmap.yaml -n $namespace
kubectl get secret -n $namespace grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo