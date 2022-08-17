#!/usr/bin/env bash

#installing k3s
if ! command -v k3s &> /dev/null
then
    echo "------- K3S could not be found let's install it -------"
    curl -sfL https://get.k3s.io | sh -
    sudo chown -R vagrant /etc/rancher/k3s/
    sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml list
    ##getting pid of installation to wait until completed
    PID_K3S_INSTALLATION=$!
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    #appending variable to bashrc if not exists (to prevent mutliple lines added after repeated provision executions)
    grep -qxF 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' ~/.bashrc || echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
    ##must wait web interface of k3s is available to prevent errors on provisioning
    wait $PID_K3S_INSTALLATION
fi
echo "Pods running:"
k3s kubectl get pods --all-namespaces -o wide

#sogno-demo DATABUS: install rabbitmq via helm
# The `rabbitmq_values.yaml` file contains SOGNO specific overwrites of the default rabbitMQ values.
cat > /etc/rancher/k3s/rabbitmq_values.yaml<< EOF
extraPlugins: rabbitmq_mqtt

service:
  extraPorts:
    - name: mqtt
      port: 1883
      targetPort: 1883
  nodePort: LoadBalancer

auth:
  username: admin
  password: admin
EOF

RABBITMQISRUNNING=`k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pod rabbitmq-0 --output="jsonpath={.status.containerStatuses[*].ready}" | cut -d' ' -f2`
echo "Rabbitmq already running? $RABBITMQISRUNNING";
if [ ! "$RABBITMQISRUNNING" = true ] ;
then
    echo "Installazione di rabbitmq"
    sudo helm install -f /etc/rancher/k3s/rabbitmq_values.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml rabbitmq bitnami/rabbitmq
fi

cd example-deployments/pyvolt-dpsim-demo
# Influx db
sudo helm install influxdb influxdata/influxdb --kubeconfig /etc/rancher/k3s/k3s.yaml -f database/influxdb-helm-values.yaml
# DB adapter
sudo helm install telegraf influxdata/telegraf --kubeconfig /etc/rancher/k3s/k3s.yaml -f ts-adapter/telegraf-values.yaml
# Grafana http://localhost:31230  Username and password for Grafana are set to "demo".
sudo helm install grafana grafana/grafana --kubeconfig /etc/rancher/k3s/k3s.yaml -f visualization/grafana_values.yaml
kubectl apply -f visualization/dashboard-configmap.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml
# Pintura http://localhost:31234
sudo helm install pintura sogno/pintura --kubeconfig /etc/rancher/k3s/k3s.yaml -f cim-editor/pintura_values.yaml
# DPsim Simulation
sudo helm install dpsim-demo sogno/dpsim-demo --kubeconfig /etc/rancher/k3s/k3s.yaml
# State-Estimation
sudo helm install pyvolt-demo sogno/pyvolt-service --kubeconfig /etc/rancher/k3s/k3s.yaml -f state-estimation/se_values.yaml
echo "Pods running:"
k3s kubectl get pods --all-namespaces -o wide
