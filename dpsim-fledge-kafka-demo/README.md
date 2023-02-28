
# DPsim - Fledge - Kafka - Demo

The rough data path in this demo is:
1. Simulate a power grid using DPsim.
2. Collect the data using Fledge with the IEC60870-5-104 protocol.
3. Send the data from Fledge to a Kafka broker.
4. Import the data from Kafka into InfluxDB using Telegraf & Starlark.

# Setup

### Helm Repos

Ensure that the following Helm Chart Repos are set up or add them locally:

```bash
helm repo add sogno https://sogno-platform.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add influxdata https://influxdata.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Hugepages

DPsim will need 2GB of HugePages or more specifically `1024` HugePages of size `2048kB`.

1. Check your current Hugepages using:
```sh
cat /proc/meminfo | grep HugePages_Total
```

2. If you do not have enough Hugepages allocate them using:
```sh
# write dirty caches from RAM to disk
sync
# drop all non-dirty caches (hopefully freeing enough contiguous memory to allocate new hugepages)
echo 3 | sudo tee /proc/sys/vm/drop_caches
# request 1024 hugepages
echo 1024 | sudo tee /proc/sys/vm/nr_hugepages
```

3. Check the Hugepages again. If there aren't enough allocated you may need to reboot.

NOTE: If you are using `k3s`, you may also need to restart your `k3s` service for it to update it's internal count of allocatable hugepages.

## DPsim

You can deploy an example DPsim configuration using the `sogno/dpsim-iec104-demo` image.
The Dockerfile for this Chart can be found in [`docker/dpsim-iec104-demo`].

```sh
helm install dpsim sogno/dpsim-iec104-demo
```

## Fledge

You can deploy an example Fledge configuration using the `sogno/fledge-s104-nkafka-demo` image.

```sh
helm install fledge sogno/fledge-s104-nkafka-demo
```

## Kafka

The default config using the plain text listener will suffice for this demo.

```sh
helm install kafka bitnami/kafka
```

## Telegraf

Telegraf receives the collected samples does some basic processing using `starlark` and stores the samples into the InfluxDB.

```sh
helm install telegraf influxdata/telegraf -f telegraf/telegraf-values.yaml
```

## InfluxDB

InfluxDB stores all samples received by Kafka.

```sh
helm install influxdb influxdata/influxdb -f influxdb/influxdb-values.yaml
```

## Graphana

The `dashboard-configmap.yaml` preconfigures Graphana to display the readings in the influxdb.

```sh
k3s kubectl apply -f grafana/dashboard-configmap.yaml
helm install grafana grafana/grafana -f grafana/grafana-values.yaml
```

# Inspecting and Debugging

The `fledge` and `dpsim` deployments are configured to expose a `ClusterIP` which can be found using:

```bash
kubectl get svc
```

## DPsim

If check the values DPsim is emitting before starting up fledge, you can use e.g. https://github.com/riclolsen/qtester104.

You should then connect to the DPsim service ClusterIP and check the 'Point Mapping' checkbox to see all messages.

## Connecting a Fledge GUI

If you want to check the state of the fledge data aquisition you can get a docker container with the GUI at https://github.com/fledge-iot/fledge-gui.

You can then point the GUI towards the ClusterIP of the fledge service.
