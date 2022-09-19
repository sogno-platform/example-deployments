#!/usr/bin/env bash
cd /home/vagrant
#first of all we need to install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

getent group docker ||sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -aG docker vagrant && newgrp docker #bash scritps are run as root on provisioning

#sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
#sudo chmod g+rwx "$HOME/.docker" -R


#minikube requires golang and cri-dockerd
cd /home/vagrant
git clone https://github.com/Mirantis/cri-dockerd.git
sudo apt-get install golang -y
cd /home/vagrant/cri-dockerd
mkdir -p bin
go get && go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
sudo install -o vagrant -g vagrant -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

#helm requires the kubectl configuration stored in ~/.kube/config so it must be available also for root
mkdir -p /root/.kube
cp /home/vagrant/.kube/config /root/.kube/config
chmod 644 /root/.kube

minikube kubectl -- get po -A #install compliant version of kubectl
minikube start --force

cd /home/vagrant/example-deployments/simulation-demo
set -o nounset
set -o errexit

#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

#cleanup in case of halted vm wich is reprovisioning
#kubectl delete deployments --all
#kubectl delete services --all
#kubectl delete pods --all --grace-period=0 --force
#kubectl delete daemonset --all

#echo "Starting rabbitmq"
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/rabbitmq/deployment.yaml 
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/rabbitmq/service.yaml 

REDISISRUNNING=`kubectl get pod redis-master-0 --output="jsonpath={.status.containerStatuses[*].ready}" | cut -d' ' -f2`
echo "Redis already running? $REDISISRUNNING";
if [ ! "$REDISISRUNNING" = true ] ;
then
    echo "installing redis" 
    sudo helm install redis --set auth.enabled=false bitnami/redis 
    echo "installed redis"
fi

#echo "Starting minio"  
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/minio/deployment.yaml 
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/minio/service.yaml 
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/minio/configmap.yaml 
#

minikube ssh docker pull amazon/aws-cli
#
echo "Creating sogno-platform bucket"
kubectl run --rm -i --tty aws-cli --overrides='
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
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/file-service/deployment.yaml
kubectl apply -f /home/vagrant/example-deployments/simulation-demo/file-service/configmap.yaml

echo "Starting dpsim api" &&
sudo helm install dpsim-api sogno/dpsim-api 
echo "Starting dpsim worker" && 
sudo helm install dpsim-worker sogno/dpsim-worker 


#passing configuration to minikube kubectl commands
mkdir -p /home/vagrant/.kube
sudo kubectl config view --raw  >> /home/vagrant/.kube/config

echo "Pods running:"
sudo kubectl get pods -o wide