#!/usr/bin/env bash

cd example-deployments/pmu-data-visualization

sudo helm install -n sogno-datavis-demo --create-namespace -f databus/rabbitmq_values.yaml rabbitmq bitnami/rabbitmq
sudo helm install influxdb influxdata/influxdb -n sogno-datavis-demo -f ts-database/influxdb-helm-values.yaml
kubectl --namespace sogno-datavis-demo get pods

#TODO:
#Find the pod
#
#$ kubectl --namespace sogno-datavis-demo get pods
#Login to the pod
#
#$ kubectl --namespace sogno-datavis-demo exec -i -t [pod name] /bin/sh
#Run influxdb CLI
#
#$ influx
#Create database and user telegraf and grant access
#
#> CREATE DATABASE telegraf
#> SHOW Databases
#> CREATE USER telegraf WITH PASSWORD 'telegraf'
#> GRANT ALL ON "telegraf" TO "telegraf"


sudo helm install grafana stable/grafana -f visualization/grafana_values.yaml
kubectl get secret -n sogno-datavis-demo grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo