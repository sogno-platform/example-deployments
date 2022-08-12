#!/usr/bin/env bash

#cleanup in case of halted vm wich is reprovisioning
k3s kubectl delete deployments --all
k3s kubectl delete services --all
k3s kubectl delete pods --all --grace-period=0 --force
k3s kubectl delete daemonset --all

# some necessary fixes
cat > example-deployments/pmu-data-visualization/ts-adapter/telegraf.conf<< EOF
[[outputs.influxdb]]
  urls = ["http://influxdb:8086"]
  database = "telegraf"
  skip_database_creation = false
  username = "telegraf"
  password = "telegraf"
  retention_policy = ""
  write_consistency = "any"
  timeout = "5s"

[[inputs.mqtt_consumer]]
  servers = ["tcp://rabbitmq:1883"]

  ## Topics that will be subscribed to.
  topics = [
    "/pmu/dev",
    "/pmu/field"
  ]

  ## Username and password to connect MQTT server.
  username = "admin"
  password = "admin"

  data_format = "json_struct"
  json_struct_name = "sogno-device"
EOF


cp -f example-deployments/pyvolt-dpsim-demo/visualization/grafana_values.yaml example-deployments/pmu-data-visualization/visualization/

cd example-deployments/pmu-data-visualization

# rabbitMQ
sudo helm install rabbitmq bitnami/rabbitmq --kubeconfig /etc/rancher/k3s/k3s.yaml -f databus/rabbitmq_values.yaml 
# Influx db
sudo helm install influxdb influxdata/influxdb --kubeconfig /etc/rancher/k3s/k3s.yaml -f database/influxdb-helm-values.yaml
# Grafana
sudo helm install grafana grafana/grafana --kubeconfig /etc/rancher/k3s/k3s.yaml -f visualization/grafana_values.yaml

#patched version of Telegraf as a database adapter, we deploy the adapter in conjunction with the created config map
k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml apply -k ts-adapter/
k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml apply -f ts-adapter/telegraf-deployment.yaml

# wait until all the pods are running
k3s kubectl wait --for=condition=Ready pods --all
# start manually telegraf into the pod with the patched telegraf version 
TELEGRAFPODNAME=$(k3s kubectl get pods | grep telegraf | awk '{print $1}')
k3s kubectl wait --for=condition=Running pod $TELEGRAFPODNAME
# relaunch it detached (started previously in the image rwthacs/telegraf-sogno )
k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml exec $TELEGRAFPODNAME -- bash -c './go/bin/telegraf'> /dev/null 2>&1 &

echo "Pods running:"
k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pods -o wide
echo "Password for Web UI:"
k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo