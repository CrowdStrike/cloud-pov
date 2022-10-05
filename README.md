# gtm-eks-pov

## Launching the Stack

  1. Upload contents of /templates to an S3 Bucket in your AWS Account
  2. Copy the Object URL for entry.yaml
  3. In CloudFormation, Create Stack with New Resources
  4. Choose Template is Ready and Amazon S3 URL
  5. Paste Object URL and click Next
  6. Enter Stack Name and configure Parameters.

## Parameters Guide

### Prerequisites
- EnvAlias: this will be appended to most created resources for identification
- S3Bucket: this is the S3 Bucket name where you uploaded the templates
- PermissionBoundary: this is the permission boundary name if required.  For example, when launching in a CloudShare account, this value should be BoundaryForAdministratorAccess

### EKS and Sensor Details
- EC2orFargate: choose whether to launch EKS Nodes on EC2, Fargate or Both
- KubernetesVersion: leave as default, but can change when required
- FalconSensorType: NodeSensor or ContainerSensor. Note: ContainerSensor is required here if EC2orFargate = Fargate

### Create New VPC
- CreateNewVPC: Leave as True unless you are creating a new VPC
- NewVPCCIDR: Leave as default, if changed make sure it is still a /24

### Use Customer VPC (Optional, skip if CreateNewVPC = True)
- CustomerVPCID: The ID of the VPC to launch resources in
- CustomerVPCCIDR: The CIDR of the VPC to launch resources in
- CustomerSubnetID1: Subnet 1 of the VPC to launch eks in
- CustomerSubnetID2: Subnet 2 of the VPC to launch eks in
- CustomerSubnetID3: Subnet of the VPC to launch Bastion in

### Configure Falcon Keys
- FalconCID: must be lower case and do not include last three chars. This can be completed easily with the following commands in your terminal or bash shell.
```bash
myCID="<Enter your CID here>"
myNewCID=$(echo $myCID | cut -c -32 | tr '[:upper:]' '[:lower:]')
echo $myNewCID
```
- CrowdStrikeCloud: Acceptable values include us-1, us-2 or eu-1
- FalconClientID: Your Falcon API Client ID
- FalconClientSecret: Your Falcon API Client Secret
- DockerAPIToken: Docker API Token generated for the Falcon CID to register EKS

### Optional Monitoring Stack
- InstallPrometheus: Helm chart to run Prometheus on EKS for performance monitoring

### Optional Bastion Host
- CreateBastion: Change to true to get a preconfigured Bastion with access to kubectl
- KeyPairName: if CreateBastion=true then please provide valid Key Pair
- RemoteAccessCIDR: if CreateBastion=true then please provide valid IP range for SSH

### Optional Detection Container
- InstallDetectionContainer: Rather or not to deploy the [detection container](https://github.com/CrowdStrike/detection-container) to the EKS cluster.

## Architecture

![image](https://user-images.githubusercontent.com/29733103/194160831-749eca87-85a3-4529-87d0-6cd737daf4f8.png)

## Prometheus Monitoring

### Connecting to Grafana

You can use port-forwarding to connect to Grafana:

```bash
kubectl port-forward service/prometheus-grafana 3001:80 -n prometheus
```

Then open [http://localhost:3001](http://localhost:3001) in your browser.

> Note: You do not need to use port 3001, you can use any port you want. However, you will need to target port 80 in the port-forward command. For example, if you want to use port 3002, you would run `kubectl port-forward service/prometheus-grafana 3002:80 -n prometheus`.

To login to Grafana, use the username `admin` and the password `prom-operator`.
