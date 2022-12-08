# CrowdStrike Falcon Proof of Value for Google Cloud Kubernetes Engine (GKE)

## Introduction

This Proof of Value (PoV) guide is designed to quickly deploy the core infrastructure needed to demonstrate the value of CrowdStrike Falcon in Google Kubernetes Engine (GKE). 

The solution allows the user to leverage Terraform to easily deploy GKE on standard pay-per-node or Autopilot pay-per-pod clusters with the Falcon Operator, Falcon Sensor and Kubernetes Protection Agent pre-installed as well as optional Detection Container to generate sample detections and Prometheus stack for monitoring.

## PoV Prerequisites

### Terraform

To use Terraform you will need to install it. HashiCorp distributes Terraform as a binary package. You can also install Terraform using popular package managers such as Homebrew.  The minimum version required for this POV is 1.0.0

### Google Cloud

#### gcloud CLI

The Google Cloud CLI is a set of tools to create and manage Google Cloud resources. You can use these tools to perform many common platform tasks from the command line or through scripts and other automation.  This tool will allow you to authenticate to GCP, retrieve GKE Cluster credentials and configure kubectl.

Once gcloud CLI is installed, you must initialize the default configuration.  This will include authorizing the gcloud CLI to use your user account credentials to access Google Cloud, and setting up a gcloud CLI configuration and sets a base set of properties, including the active account from the step above, the current project, and default region.

1. To initialize the gcloud CLI run:
```
gcloud init
```
Follow the prompts to complete setup to configure the gcloud CLI with your GCP credentials.

2. Set up Application Credentials
```
gcloud auth application-default login
```
This obtains your credentials via a web flow and stores them in 'the well-known location for Application Default Credentials'. Now terraform will be able to find the credentials automatically. For more information: Authorize the gcloud CLI | Google Cloud CLI Documentation 

#### Enable API Services

Your Google Cloud Project must have the Google Kubernetes Engine API enabled to allow the creation and management of GKE clusters and supporting components.  The following steps show how to enable the API via the gcloud CLI.

1. Enter the following to return a list of APIs currently enabled for your Google Cloud project:
```
gcloud services list --enabled
```

2. If you don't see the API “container.googleapis.com Kubernetes Engine API” listed, that means you must enable the API. Using the applicable service name from the previous step, enable the service:
```
gcloud services enable container.googleapis.com
```

### Required Permissions

If you intend to create a specified role to enforce least privilege, we have included a GCP role definition in the codebase, cs-gke-pov-role.yml (see step How to Deploy).  This role definition contains a list of permissions that are sufficient to apply, update and destroy the terraform configuration in this POV Template.  Please note that GCP permissions requirements are subject to change.

### Resource Requirements
- The GKE Proof of Value template will deploy the following resources:
- VPC Network with 3 Subnets
- GKE Cluster
- The option between a Standard Node Pool or Autopilot
- If a Standard Node Pool is selected
    - Machine Type: n1-standard-1
    - Node Count: 1 per zone (optional)
- The option between COS and Ubuntu
- Optional Prometheus Monitoring Stack installed via Helm
- Optional Detection Container for auto-generated detections

### CrowdStrike Falcon API Client

An API client is an identity mechanism that provides secure access to the CrowdStrike API. It contains credentials and scoped permissions to access specific API resources. You create an API client to generate your OAuth 2.0 client ID and secret credentials, which you exchange in the authentication flow for an access token that authorizes API requests.

### Kubernetes Protection Agent Configuration

The Kubernetes Protection Agent (KPA) configuration consists of specific settings to allow the KPA to be installed and to be registered with Falcon. For the GKE PoV especially the DockerAPIToken is required to download (pull) the KPA container image from the CrowdStrike container registry.  The KPA configuration includes the DockerAPIToken, Falcon cloud region and Falcon CID and can be obtained from Falcon Console.

## How to Deploy

To retrieve the files you may download a zip or use git:
```
git clone https://github.com/CrowdStrike/cloud-pov.git
```

### Set Variables

There are several variables that must be set to successfully deploy this POV configuration.  These variables are defined in gke-pov.tfvars. This file allows you to assign values to all variables in one place.  All string values should be wrapped in quotes, eg. “string”, while booleans (true or false) and numbers do not need quotes.  The below table gives details about each variable assignment.

| Variable | Type | Description | Default Value | Optional Value |
|----|----|----|----|----|
| project | string | GCP Project ID, this can be retrieved from key file | “pr-***” | N/A |
| region | string | GCP Region | “us-east1” | Any GCP Region |
| alias | string | Prefix for resource names | “pov” | Any string |
| subnet_cidr_1 | string | CIDR Range for Subnet | “10.0.1.0/24” | Any valid CIDR |
| subnet_cidr_2 | string | CIDR Range for Subnet | “10.0.2.0/24” | Any valid CIDR |
| subnet_cidr_3 | string | CIDR Range for Subnet | “10.0.3.0/24” | Any valid CIDR |
| cluster_name | string | GKE Cluster Name | “my-cluster” | Any string |
| gke_num_nodes | number | GKE Nodes per Zone | 1 | 2+ |
| node_os | string | GKE Node OS, If you choose COS, sensor_type must equal “FalconContainer” | “UBUNTU_CONTAINERD” | “COS_CONTAINERD” |
| autopilot | boolean | Whether to deploy GKE on Autopilot, if true, sensor_type must = “FalconContainer” and prometheus must = false | false | true |
| sensor_type | string | Falcon Node Sensor or Container | “FalconNodeSensor” | “FalconContainer” |
| cid | string | Falcon CID, all Lower with no checksum | | N/A |
| crowdstrike_cloud | string | CrowdStrike Cloud for your CID | “us-1” | “us-2” or “eu-1” |
| client_id | string | Falcon API Client ID | | N/A |
| client_secret | string | Falcon API Client Secret | | N/A |
| docker_token | string | Falcon Docker Token | | N/A |
| detection_container | boolean | Whether to deploy CrowdStrike Detection Container | false | true |
| prometheus | boolean | Whether to deploy Prometheus Monitoring Stack | false | true |

### Run Terraform

1. Initialize terraform
**Note:** The following commands must be run from cloud-pov/gcp-gke-pov/ directory
```
terraform init
```

2. Plan terraform
```
terraform plan -var-file=gke-pov.tfvars
```
Review plan output for any errors and confirm configuration

3. Apply terraform
```
terraform apply -var-file=gke-pov.tfvars
```
**Note:** The configuration will take approximately 20 minutes to complete.


## Validate Successful PoV Deployment

### Validate Falcon Integration

To validate the successful deployment of Falcon components and integration into Falcon, open the Falcon Console.

Kubernetes Protection Agent (KPA) deployment can be validated by navigating to Menu → Cloud security → Account registration in Falcon Console. On this page select Kubernetes, select Active Clusters and validate that the GKE cluster is visible and has the Status of Agent Running.

To validate deployment of the Falcon Sensor deployment navigate to Menu → Host setup and management → Host management. This list contains all Falcon managed hosts in the environment. To filter for the PoV environment hosts the easiest way is to filter for the grouping tag SensorGroupingTags/cs-pov.

### Connect to Cluster

1. Update Kube Config
```
gcloud container clusters get-credentials pov-my-cluster --region us-east1
```

2. Test Access and Verify Deployment
Once kubeconfig is configured on your local machine, execute the following two kubectl commands to validate deployment of the components.
```
kubectl get nodes
Kubectl get pods --all-namespaces
```

### Review Detections in Falcon
If the optional Detection Container has been deployed, the detection-container pod (see above) will randomly create detections. Between each detection the container will pause for a randomized amount of time ranging from 100 to 1800 seconds (roughly 1.5 - 30 minutes). This pause ensures events trigger unique detections in the Falcon console that are not grouped together.

1. Open the Falcon Console and navigate to Menu → Endpoint security → Endpoint detections to view the detections generated by the detection-container pod.

### Monitoring with Prometheus and Grafana
Prometheus is an open-source systems monitoring and alerting toolkit based on a multi-dimensional data model with time series data identified by metric name and key/value pairs. Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources like Prometheus.

Prometheus and Grafana are optional deployments in this PoV to help validate if CrowdStrike CWP meets your performance needs.

#### Connecting to Grafana
To connect to Grafana and visualize performance metrics, port-forwarding can be used. Execute the following command to create a port-forwarding rule to forward requests on localhost port 3001 to port 80 on the prometheus-grafana instance.
```
kubectl port-forward service/prometheus-grafana 3001:80 -n prometheus
```

**Note:** This process will continue running in your terminal window, and must continue running to maintain access to the Grafana console.  When you need to stop the service, press [ctrl]+C. 

Open the URL http://localhost:3001 in a browser and login to Grafana using the username admin with the password prom-operator.  

Once logged into Grafana, you may explore creating queries and dashboards to monitor the performance of your GKE Cluster.  For example, a simple query can be created on the Explore page.  To start, click the compass icon on the left, then select a metric from the drop down menu and finally click Run Query to view results.

For more information on how to build queries and dashboards, please see official documentation here https://prometheus.io/docs/visualization/grafana/ 

