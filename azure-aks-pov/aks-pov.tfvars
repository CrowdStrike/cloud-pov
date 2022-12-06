
# Provider Configuration
resource_group = ""
location       = ""

alias  = "pov"

# AKS Configuration
cluster_name = "cluster"
kubernetes_version = "1.23.12" # Also available: 1.22.11, 1.22.15, 1.23.8, 1.24.3, 1.24.6, 1.25.2 (preview)
aks_num_nodes = 1 # Number of nodes to launch with
aks_min_nodes = 1 # Must be <= aks_num_nodes
aks_max_nodes = 1 # Must be >= aks_num_nodes
node_vm_size  = "Standard_B4ms"
os_sku        = "Ubuntu"

# CrowdStrike Config
# Before apply, please run: `helm repo add kpagent-helm https://registry.crowdstrike.com/kpagent-helm && helm repo update`

sensor_type = "FalconNodeSensor"  # Allowed Values: FalconNodeSensor or FalconContainer

cid = ""
crowdstrike_cloud = "" # Allowed Values: us-1, us-2 or eu-1
client_id = ""
client_secret = ""
docker_token = ""

# Other Optional Features

# CrowdStrike Detection Container
detection_container = true

# Prometheus Monitoring Stack
# If prometheus = true, please run `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update`
prometheus = true
