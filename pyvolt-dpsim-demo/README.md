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
<<<<<<< HEAD
### HugePages

<<<<<<< HEAD
The current setup requires HugePages support for the real-time simulator. This can be checked and activated as follows:
=======
The current setup requires HugePages support for the real-time simulator. This can be checked and activated (temporarily) as follows:
>>>>>>> parent of f93014c... Keycloak added for pyvolt-dpsim-demo

```bash
# Verify HugePages
cat /proc/meminfo | grep Huge

AnonHugePages:    104448 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:       0		<-- we require a minimum of 1024
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

<<<<<<< HEAD
=======
If you don't see 1024 next to HugePages_Total, you may need to restart
your system and try again with a fresh boot.

>>>>>>> parent of f93014c... Keycloak added for pyvolt-dpsim-demo
# Restart k3s service to apply changes
sudo systemctl restart k3s

# Ensure the KUBECONFIG env is still set correctly
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```
=======
>>>>>>> f93014c3016b99cde3889b3f6a055a4e15777f5a

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

The following installation will deploy a KeyCloak instance that is available at the nodePort specified in the keycloak_values.yaml file.
Per defautl at port 31250: http://localhost:31250

```bash
helm install my-release -f keycloak/keycloak_values.yaml bitnami/keycloak
```
To Get the user password for the keycloak, run this command.
```bash
 echo Password: $(kubectl get secret --namespace default my-release-keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)
```
Login to the keycloak instance. The user name is:user and use the passwrod.

Than Create a realm for common authentication for your applications.
![alt text](https://i2.wp.com/www.techrunnr.com/wp-content/uploads/2020/07/Screenshot-from-2020-07-12-22-19-43.png?w=775&ssl=1)

Create a client for grafana as given below where root url is your grafana application URL.In this case it will be "http://localhost:31230."
![alt text](https://i0.wp.com/www.techrunnr.com/wp-content/uploads/2020/07/Screenshot-from-2020-07-12-23-18-38.png?w=850&ssl=1)

Once the client is created, open the client configuration and change the access type to confidential from public. Save the config.
![alt text](https://i0.wp.com/www.techrunnr.com/wp-content/uploads/2020/07/Screenshot-from-2020-07-12-23-23-08.png?w=702&ssl=1)

Open the client grafana again and go to credentials tag and copy the client id and secret for future use.

![alt text](https://i0.wp.com/www.techrunnr.com/wp-content/uploads/2020/07/Screenshot-from-2020-07-12-23-23-32.png?w=710&ssl=1 )


### Visualization

<<<<<<< HEAD
The following installation will deploy a Grafana instance that is available at the nodePort specified in the grafana_values.yaml file. 
<<<<<<< HEAD
=======
The following installation will deploy a Grafana instance that is available at the nodePort specified in the grafana_values.yaml file.
>>>>>>> parent of f93014c... Keycloak added for pyvolt-dpsim-demo
=======
Change the client_secret with your own.
>>>>>>> f93014c3016b99cde3889b3f6a055a4e15777f5a
Per defautl at port 31230: http://localhost:31230

```bash
helm install grafana grafana/grafana -f visualization/grafana_values.yaml
kubectl apply -f visualization/dashboard-configmap.yaml
```
The configmap contains a demo dashboard and should automatically be recognized by the grafana instance. Username and password for Grafana are set to "demo".

You have to create a user in the realm you created to use the login with the keylocak feature.

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
