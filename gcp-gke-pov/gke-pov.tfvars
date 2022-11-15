
# Provider Configuration
credentials = "my-gcp-key.json"
project     = "pr-****"
region      = "us-east1"

# Optional Features
autopilot = false
prometheus = false
detection_container = false

# Infrastructure Configuration
alias  = "pov"

private_subnet_cidr_1 = "10.0.1.0/24"
private_subnet_cidr_2 = "10.0.2.0/24"
private_subnet_cidr_3 = "10.0.3.0/24"
public_subnet_cidr_1  = "10.0.4.0/24"
public_subnet_cidr_2  = "10.0.5.0/24"
public_subnet_cidr_3  = "10.0.6.0/24"

# GKE Configuration
cluster_name = "my-cluster"
gke_num_nodes = 2

# Kubernetes Protection Agent
protection_agent = true # if true run: `helm repo add kpagent-helm https://registry.crowdstrike.com/kpagent-helm && helm repo update`

cid = ""
crowdstrike_cloud = "us-1"
client_id = ""
client_secret = ""
docker_token = ""