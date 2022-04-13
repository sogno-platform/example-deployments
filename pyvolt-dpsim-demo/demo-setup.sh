#!/bin/bash

helm install rabbitmq bitnami/rabbitmq -f databus/rabbitmq_values.yaml

helm install influxdb influxdata/influxdb -f database/influxdb-helm-values.yaml

helm install telegraf influxdata/telegraf -f ts-adapter/telegraf-values.yaml

helm install my-release -f keycloak/keycloak_values.yaml bitnami/keycloak

sleep 5m

python3 keycloak/keycloak_creation.py 

helm install grafana grafana/grafana -f visualization/grafana_values.yaml

kubectl apply -f visualization/dashboard-configmap.yaml

helm install pintura sogno/pintura -f cim-editor/pintura_values.yaml 

helm install dpsim-demo sogno/dpsim-demo

helm install pyvolt-demo sogno/pyvolt-service -f state-estimation/se_values.yaml

kubectl get pods