#!/usr/bin/env bash

cd example-deployments/simulation-demo
set -o nounset
set -o errexit

#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

#cleanup in case of halted vm wich is reprovisioning
k3s kubectl delete deployments --all
k3s kubectl delete services --all
k3s kubectl delete pods --all --grace-period=0 --force
k3s kubectl delete daemonset --all

echo "Starting rabbitmq"
k3s kubectl apply -f ./rabbitmq/deployment.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml
k3s kubectl apply -f ./rabbitmq/service.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml

REDISISRUNNING=`k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pod redis-master-0 --output="jsonpath={.status.containerStatuses[*].ready}" | cut -d' ' -f2`
echo "Redis already running? $REDISISRUNNING";
if [ ! "$REDISISRUNNING" = true ] ;
then
    echo "installing redis" 
    sudo helm install redis --set auth.enabled=false bitnami/redis --kubeconfig /etc/rancher/k3s/k3s.yaml
    echo "installed redis"
fi

echo "Starting minio"  
k3s kubectl apply -f ./minio/deployment.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml
k3s kubectl apply -f ./minio/service.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml
k3s kubectl apply -f ./minio/configmap.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml

#installing minikube
#curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
#sudo dpkg -i minikube_latest_amd64.deb
#minikube ssh docker pull amazon/aws-cli

echo "Creating sogno-platform bucket"
k3s kubectl run --kubeconfig /etc/rancher/k3s/k3s.yaml --rm -i --tty aws-cli --overrides='
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
      "name": "aws-cli"
  },
  "spec": {
    "containers": [
      {
        "name": "aws-cli",
        "command": [ "/root/.aws/setup" ],
        "spacer": [ "bash" ],
        "image": "amazon/aws-cli",
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "volumeMounts": [
          {
            "mountPath": "/root/.aws",
            "name": "credentials-volume"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "credentials-volume",
        "configMap":
        {
          "name": "aws-config",
          "path": "/root/.aws",
          "defaultMode": 511
        }
      }
    ]
  }
}
'  --image=amazon/aws-cli --restart=Never --


echo "Starting file service" &&
k3s kubectl apply -f ./file-service/deployment.yaml
k3s kubectl apply -f ./file-service/configmap.yaml


echo "Starting dpsim api" &&
sudo helm install dpsim-api sogno/dpsim-api --kubeconfig /etc/rancher/k3s/k3s.yaml
echo "Starting dpsim worker" && 
sudo helm install dpsim-worker sogno/dpsim-worker --kubeconfig /etc/rancher/k3s/k3s.yaml

echo "Pods running:"
k3s kubectl get pods --all-namespaces -o wide