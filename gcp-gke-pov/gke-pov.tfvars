
# Provider Configuration
credentials = "my-gcp-key.json"
project     = "pr-****"
region      = "us-central1"
zone        = "us-central1-c"

# Optional Features
autopilot = false
bastion = false
prometheus = false
detection-container = false

# Infrastructure Configuration
alias  = "pov"

private-subnet-cidr-1 = "10.0.1.0/24"
private-subnet-cidr-2 = "10.0.2.0/24"
private-subnet-cidr-3 = "10.0.3.0/24"
public-subnet-cidr-1  = "10.0.4.0/24"
public-subnet-cidr-2  = "10.0.5.0/24"
public-subnet-cidr-3  = "10.0.6.0/24"

# GKE Configuration
gke-num-nodes = 2