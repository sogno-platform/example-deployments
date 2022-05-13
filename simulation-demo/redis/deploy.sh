#!/bin/bash
#kubectl apply -f deployment.yaml
#helm install redis --set auth.existingSecret=redis-secret bitnami/redis

helm install redis --set auth.enabled=false bitnami/redis
