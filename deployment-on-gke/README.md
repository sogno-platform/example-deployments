# Pyvolt DPSim Demo on Google Cloud Platform

Follow the instructions here to deploy the [Pyvolt DPSim demo ](https://github.com/sogno-platform/example-deployments/tree/main/pyvolt-dpsim-demo) on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).

NOTE: in the following we also provide instructions to deploy the demo on a GKE cluster supporting [Anthos Service Mesh (ASM)](https://cloud.google.com/anthos/service-mesh), the GCP service mesh solution based on the Istio open source project. Although not strictly needed to have a fully functional demo, ASM offers advanced features such as out-of-the-box service observability, intelligent traffic management, inter-service mTLS authentication, circuit breaking, fault injection.

# Requirements

Before starting, you need to have: 
- an active GCP account
- a project where you have full permissions (Project Owner role)
- a VPC with a subnet in the cloud region where you want to create the GKE cluster

Enable the API needed to deploy a GKE cluster, and, in case you want to activate the Anthos Service Mesh, also Anthos API.

# Create the GKE cluster

You can select between either of the following options:
1) GKE cluster without Anthos Service Mesh 
2) GKE cluster with Anthos Service Mesh
Note that with both options GKE Standard mode is required.

## GKE cluster without Anthos Service Mesh 

A tested command for creating the GKE cluster through gcloud shell is as follows:

	gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --region $REGION --no-enable-basic-auth --cluster-version $VERSION --release-channel "regular" --machine-type "e2-standard-4" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "2" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM,WORKLOAD --enable-ip-alias --network "projects/$PROJECT_ID/global/networks/$VPC" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/$SUBNET" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes

where the variables are:
- PROJECT_ID: the project id of your project
- CLUSTER_NAME: the name you want to give to your cluster
- REGION:  the cloud region you want to use as cluster location
- VERSION: GKE software version (my test has been done on the "1.22.8-gke.202", but any 1.22 should be fine)
- VPC: the name of your VPC
- SUBNET: the name of your subnet

Please note that not all of the features configured above (such as shielded nodes or GKE addons) are required for the demo. They can be customized as you prefer.


## GKE cluster with Anthos Service Mesh 

A tested command for creating a GKE cluster through a gcloud shell is as follows:

	gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --region $REGION --no-enable-basic-auth --cluster-version $VERSION --release-channel "regular" --machine-type "e2-standard-4" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "2" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM,WORKLOAD --enable-ip-alias --network "projects/$PROJECT_ID/global/networks/$VPC" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/$SUBNET" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --labels mesh_id=proj-172504251858 --workload-pool "$PROJECT_ID.svc.id.goog" --enable-shielded-nodes

where:
- PROJECT_ID is the project id of your project
- CLUSTER_NAME is the name you want to give to your cluster
- REGION is the cloud region you want to use as cluster location
- VERSION is GKE software version (my test has been done on the "1.22.8-gke.202", but any 1.22 should be fine)
- VPC is the name of your VPC
- SUBNET is the name of your subnet

Please note that:
- ASM is deployed in its [managed option](https://cloud.google.com/service-mesh/docs/overview#managed_anthos_service_mesh)
- Workload Identity is a requirement for ASM

ASM installation might require additional time, even 15 minutes more than normal GKE cluster creation time. After that create the namespace to deploy the demo and apply automatic injection of ASM sidecar containers to enable ASM on all pods in the namespace:

	gcloud container clusters get-credentials CLUSTER_NAME --region REGION
	kubectl create namespace NAMESPACE
	kubectl label namespace NAMESPACE istio-injection=enabled istio.io/rev- --overwrite

# Enable huge pages on GKE
Huge pages are required by the DPSim demo microservice. 
In order to enable them on a GKE cluster, create the following K8s daemonset:

	kubectl apply -f manifests/enable-thp.yaml

Label all nodes of the nodepool where you want to configure huge pages (the default nodepool in this example):

	gcloud container node-pools update default-pool --node-labels=gke-thp=true --region $REGION --cluster $CLUSTER_NAME

After completion of the labelling, the daemonset will be automatically started on all nodes and run a script to configure and activate huge pages.

# Deploy your DPSim demo

Follow the instructions as detailed in the Pyvolt DPSim demo README to deploy all the containerized components through the Helm charts.

# Expose Grafana and Pintura services
In order to externally expose services running on GKE, you need to create a K8S Service of [type LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer). This will in turn create GCP Network Load Balancers with public IP addresses. 
To do that:

	kubectl apply -f manifests/grafana-service.yaml -n $NAMESPACE
	kubectl apply -f manifests/pintura-service.yaml -n $NAMESPACE