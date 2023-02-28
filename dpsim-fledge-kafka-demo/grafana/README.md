# Visualization

The visualization is based grafana installed with the official grafana helm chart. We provide a custom values file for integrating grafana with this demo as well as a demo dashboard.

## Helm Values

Adjust the the hostname in the kubernetes ingress section of the values file before deploying Grafana.

```yaml

ingress:
  enabled: true
  hosts:
    -  hostname.example.org  # put fqdn or ip here
  path: /

```

## Demo Dashboard

This demo deployment supports the automatic loading of dashboards into the grafana pod.
This is realized my means of a config-map containing a grafana dashboard in json format.

The config-map for the demo dashboard can be created as follows:

```bash

$ kubectl apply -f dashboard-configmap.yaml

``` 
