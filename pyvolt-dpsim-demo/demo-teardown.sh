#!/bin/bash

helm uninstall rabbitmq

helm uninstall influxdb

helm uninstall telegraf

helm uninstall grafana
kubectl delete -f visualization/dashboard-configmap.yaml

helm uninstall pintura 

helm uninstall dpsim-demo

helm uninstall pyvolt-demo
