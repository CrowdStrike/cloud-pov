
# Provider Configuration
credentials = "my-gcp-key.json"
project     = "pr-****"
region      = "us-central1"
zone        = "us-central1-c"

# Optional Features
autopilot = false
bastion = false
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
gke_num_nodes = 2