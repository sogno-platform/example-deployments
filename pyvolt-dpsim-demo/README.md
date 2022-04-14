# Pyvolt DPsim Demo

## Preliminaries

Follow the instructions here to get started:
https://sogno-platform.github.io/docs/getting-started/

Clone this repo:
```bash
git clone https://github.com/sogno-platform/example-deployments.git
cd example-deployments/pyvolt-dpsim-demo
```

### Helm Repos

Ensure that the following Helm Chart Repos are set up or add them locally:

```bash
helm repo add sogno https://sogno-platform.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add influxdata https://influxdata.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
### HugePages

The current setup requires HugePages support for the real-time simulator. But if you want a keycloak sso service, do not do this. This can be checked and activated (temporarily) as follows:

```bash
# Verify HugePages
cat /proc/meminfo | grep Huge

AnonHugePages:    104448 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:       0        <-- we require a minimum of 1024
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:               0 kB

# Increase No of HPgs
echo 1024 | sudo tee /proc/sys/vm/nr_hugepages

# Check it worked
cat /proc/meminfo | grep Huge

AnonHugePages:    104448 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:    1024
HugePages_Free:     1024
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:         2097152 kB

If you don't see 1024 next to HugePages_Total, you may need to restart
your system and try again with a fresh boot.

# Restart k3s service to apply changes
sudo systemctl restart k3s

# Ensure the KUBECONFIG env is still set correctly
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

## Manual Chart Installation

### Databus

```bash
helm install rabbitmq bitnami/rabbitmq -f databus/rabbitmq_values.yaml
```

### Database

```bash
helm install influxdb influxdata/influxdb -f database/influxdb-helm-values.yaml
```

### Database Adapter

```bash
helm install telegraf influxdata/telegraf -f ts-adapter/telegraf-values.yaml
```

### KeyCloak:    

The following installation will deploy a KeyCloak instance that is available at the nodePort specified in the keycloak_values.yaml file. The username and password both are "user" for the admin panel.
Per default at port 31250: http://localhost:31250

```bash
helm install my-release -f keycloak/keycloak_values.yaml bitnami/keycloak
```
Please wait for 3 minutes for the keycloak to deploy properly. To create keycloak realm, client and user run the python script keycloak_createion.py.

```bash
python3 keycloak/keycloak_creation.py 
```
### Visualization

The following installation will deploy a Grafana instance that is available at the nodePort specified in the grafana_values.yaml file. 
Per default at port 31230: http://localhost:31230

```bash
helm install grafana grafana/grafana -f visualization/grafana_values.yaml
kubectl apply -f visualization/dashboard-configmap.yaml
```
The configmap contains a demo dashboard and should automatically be recognized by the grafana instance. The username and password for Grafana are set to "demo".It's also the same in the case of login with oauth.

### CIM Editor Pintura

The following installation will deploy a Pintura instance that is available at the nodePort specified in the pintura_values.yaml file.
Per default at port 31234: http://localhost:31234/ (it may take a few moments to launch and become available)

```bash
helm install pintura sogno/pintura -f cim-editor/pintura_values.yaml
```
### DPsim Simulation

```bash
helm install dpsim   -demo sogno/dpsim-demo
```

### State-Estimation
```bash
helm install pyvolt-demo sogno/pyvolt-service -f state-estimation/se_values.yaml
```

## Automated Chart Installation

We also prepared two scripts for automatically setting up the demo. They simply run the all helm installs and uninstalls in a bash script.

```bash
# demo setup
./demo-setup.sh

# clean-up
./demo-teardown.sh
```
