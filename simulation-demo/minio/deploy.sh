#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR && echo "Changed to $SCRIPT_DIR"

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f configmap.yaml

minikube ssh docker pull amazon/aws-cli

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
