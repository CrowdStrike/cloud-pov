# CrowdStrike Falcon Proof of Value for Amazon Elastic Kubernetes Service (EKS)

## Introduction

This Proof of Value (PoV) guide is designed to quickly deploy the core infrastructure needed to demonstrate the value of CrowdStrike Falcon in Amazon Elastic Kubernetes Service (EKS). 

The solution allows the user to leverage AWS CloudFormation to easily deploy EKS on Amazon Elastic Compute Cloud (EC2) Managed Nodes or AWS Fargate with the Falcon Operator, Falcon Sensor and Kubernetes Protection Agent pre-installed as well as optional Detection Container to generate sample detections and Prometheus stack for monitoring.

## How it Works

The EKS PoV infrastructure is deployed via a series of AWS CloudFormation templates. The user will reference a root template (entry.yaml) when creating the AWS CloudFormation Stack which will automatically launch other templates as nested stacks.

The following architectural diagram illustrates the resources deployed in an AWS account. Please note that some of the resources are optional. 

![image](https://user-images.githubusercontent.com/29733103/194160831-749eca87-85a3-4529-87d0-6cd737daf4f8.png)

## PoV Prerequisites

### Amazon EC2 Key Pair

The optional Bastion Host deployment requires an existing EC2 Key Pair in the same AWS region where launching the CloudFormation Stacks. A key pair, consisting of a public key and a private key, is a set of security credentials that you use to prove your identity when connecting to an Amazon EC2 instance.

If you intend to utilize the Bastion Host, and a suitable EC2 Key Pair is not already available, please create a Key Pair prior to executing the CloudFormation Stack.

For more detailed instructions to create an EC2 Key Pair please see the official AWS Documentation at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html 

### Resource Requirements

The EKS Proof of Value Template will deploy the following resources:
- IAM Roles with various functions including CloudFormation Stack execution and EKS Access.
- CloudFormation Type Activations for both EKS Cluster and Helm
- VPC with 4 subnets, 3 route tables, IGW and NAT Gateway
- EKS Cluster and required Security Groups
- The option between an EKS Managed Node Group or Fargate Profiles.  
- If EKS Managed Node Group is selected, instance details are as follows:
    - Operating System: Amazon Linux 2
    - Instance Type: m5.large
    - Group Size: 2 nodes
    - Volume Type and Size: GP3, 80gb
- Optional Prometheus Monitoring Stack installed via Helm
- Optional Bastion Host on EC2, instance details are as follows:
    - Operating System: Amazon Linux 2
    - Instance Type: t2.small
    - Volume Type and Size: GP2, 10gb

For more details about each resource deployed via the CloudFormation template, please see the Appendix.

### CrowdStrike Falcon API Client

An API client is an identity mechanism that provides secure access to the CrowdStrike API. It contains credentials and scoped permissions to access specific API resources. You create an API client to generate your OAuth 2.0 client ID and secret credentials, which you exchange in the authentication flow for an access token that authorizes API requests.

### Kubernetes Protection Agent Configuration

The Kubernetes Protection Agent (KPA) configuration consists of specific settings to allow the KPA to be installed and to be registered with Falcon. For the EKS PoV especially the DockerAPIToken is required to download (pull) the KPA container image from the CrowdStrike container registry.  The KPA configuration includes the DockerAPIToken, Falcon cloud region and Falcon CID and can be obtained from Falcon Console.

### AWS IAM Permissions

The AWS IAM Permissions which are required to complete prerequisite actions, launch and delete the CloudFormation Stacks successfully, are included in the example IAM policy: minimum-aws-permissions.json

## How to Deploy

### Upload PoV Templates to an Amazon S3 Bucket

1. Download PoV Templates from GitHub
2. Extract the files to a local folder
3. Upload content extracted from the Zip file to an S3 bucket in your AWS Account
4. Access the AWS Account where the PoV environment will be deployed
5. Upload files to the root of an S3 bucket

### Create AWS CloudFormation Stack to Build PoV Environment

1. Copy S3 URL for entry.yaml file  
2. Create AWS CloudFormation Stack  from Amazon S3 URL

### Parameters

Prerequisites
- EnvAlias: pov (default) - Update to preferred value
- S3 Bucket: blank (default)- Update to S3 bucket location where uploaded files where placed
- PermissionsBoundary: blank (default) - A permissions boundary is an advanced feature in AWS IAM for using a managed policy to set the maximum permissions that an identity-based policy can grant to an IAM entity. If a Permissions Boundary is in place, it must be included for IAM Roles to successfully launch. For additional information - link

EKS and Sensor Details
- EC2orFargate: EC2 (default) 
- KubernetesVersion: 1.21 (default)
- FalconSensorType: FalconNodeSensor (default)

Create New VPC
- NewVPCCIDR: 10.1.0.0/24 (default)

Configure Falcon Keys - See prerequisites
- FalconCID: Enter FalconCID - All lower without Checksum
- CrowdStrikeCloud: us-1 (default)
- FalconClientID: Enter API CID
- FalconClientSecret: Enter Client Secret associated with the Falcon API CID - Enter CID
- DockerAPIToken: Enter DockerAPIToken

Optional Monitoring Stack - Update as required
- InstallPrometheus: false (default)

Optional Bastion Host - Update as required
- CreateBastion: true (default)
- KeyPairName: keyname (default) - Use the Amazon EC2 key pair name created earlier (see Amazon EC2 key pair (Bastion Host)
- RemoteAccessCIDR: 1.1.1.1/32 (default) - Change to External Public IP Address of the host running the PoV and keep the 32-bit mask to allow SSH access from a single IP address

Optional Detection Container - Update as required
- InstallDectectionContainer: False (default)

### Please note: deployment of the PoV environment will take 20-30 minutes to complete, depending on the features selected. Please see the next section for steps to validate a successful deployment.

## Validate Successful PoV Deployment
The successful deployment of the PoV environment can be tracked using the AWS and Falcon Console. The following shows the validation steps for an EKS EC2 deployment.

### Validate AWS Deployment and Falcon Integration

To validate the successful deployment of the AWS CloudFormation templates, open the AWS Console and ensure the right AWS account and location is selected. Open the CloudFormation management page, select Stacks on the left side and check the status of the CloudFormation Stacks.

To validate the successful deployment of Falcon components and integration into Falcon, open the Falcon Console.

Kubernetes Protection Agent (KPA) deployment can be validated by navigating to Menu → Cloud security → Account registration in Falcon Console. On this page select Kubernetes, select Active Clusters and validate that the EKS cluster is visible and has the Status of Agent Running.

To validate deployment of the Falcon Sensor deployment navigate to Menu → Host setup and management → Host management. This list contains all Falcon managed hosts in the environment. To filter for the PoV environment hosts the easiest way is to filter for the grouping tag SensorGroupingTags/cs-pov.

### Connect to EKS Cluster

#### Connect via Local Machine

Please Note: If you choose to launch the Prometheus Monitoring Stack, this option is required to connect to Grafana and query EKS Cluster performance data from Prometheus.

**Prerequisites**
- Install and configure AWS CLI on your machine.  For more information please see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html  

1. Update Kube Config
The IAM user who launched the Template has direct access to the EKS Cluster without switching roles.  To set up kubeconfig run the following command.
```
aws eks update-kubeconfig --region [region-code] --name [cluster-name]
```
Other IAM users may switch to the EKSAccessRole to access the EKS Cluster.  To set up kubeconfig as this type of user, just add the --role-arn argument
```
aws eks update-kubeconfig --region [region-code] --name [cluster-name] --role-arn [role-arn]
```
**Note:** to get the role-arn please visit the AWS Console, navigate to IAM and locate the EKSAccessRole

2. Test Access and Verify Deployment
Once kubeconfig is configured on your local machine, execute the following two kubectl commands to validate deployment of the components.
```
kubectl get nodes
Kubectl get pods --all-namespaces
```

#### Connect via Bastion Host

Once all CloudFormation Stacks have completed, and the Bastion Host is running, you are ready to connect to the EKS Cluster and verify the deployments.

1. Connect to the Bastion Host
SSH to the Bastion Host using the private key generated earlier and where user is ec2-user and hostname is the public IP or hostname of the Bastion Host, e.g.
```
ssh -i my-ec2-keypair.pem ec2-user@12.34.56.78
```

2. Verify the Kubernetes Deployments
Once connected via SSH to the Bastion Host, execute the following two kubectl commands to validate deployment of the components.
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

Please note that the following commands only work if the PoV EKS cluster is accessed locally via kubectl, not via the Bastion Hosts. For instructions on how to connect via your local machine, please review the earlier section “Connect via Local Machine”

#### Connecting to Grafana
To connect to Grafana and visualize performance metrics, port-forwarding can be used. Execute the following command to create a port-forwarding rule to forward requests on localhost port 3001 to port 80 on the prometheus-grafana instance.
```
kubectl port-forward service/prometheus-grafana 3001:80 -n prometheus
```

**Note:** This process will continue running in your terminal window, and must continue running to maintain access to the Grafana console.  When you need to stop the service, press [ctrl]+C. 

Open the URL http://localhost:3001 in a browser and login to Grafana using the username admin with the password prom-operator.  

Once logged into Grafana, you may explore creating queries and dashboards to monitor the performance of your EKS Cluster.  For example, a simple query can be created on the Explore page.  To start, click the compass icon on the left, then select a metric from the drop down menu and finally click Run Query to view results.

For more information on how to build queries and dashboards, please see official documentation here https://prometheus.io/docs/visualization/grafana/ 

