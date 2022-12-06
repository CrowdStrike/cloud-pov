
module "aks" {
    source = "github.com/CrowdStrike/terraform-modules/azure/aks"    
    alias  = var.alias
    location = var.location
    resource_group = var.resource_group
    cluster_name = var.cluster_name
    aks_num_nodes = var.aks_num_nodes
}

module "falcon" {
    source = "github.com/CrowdStrike/terraform-modules/falcon/operator"
    client_id = var.client_id
    client_secret = var.client_secret
    sensor_type = var.sensor_type
    environment = var.alias
}

module "protection_agent" {
    source = "github.com/CrowdStrike/terraform-modules/falcon/k8s-protection-agent"
    protection_agent_config = <<EOF
crowdstrikeConfig:
  clientID: ${var.client_id}
  clientSecret: ${var.client_secret}
  clusterName: ${var.alias}-${var.cluster_name}
  dockerAPIToken: ${var.docker_token}
  cid: ${var.cid}
  env: ${var.crowdstrike_cloud}
EOF
}

module "detection_container" {
    source = "github.com/CrowdStrike/terraform-modules/falcon/detection-container"
    count = var.detection_container == true ? 1 : 0
}
    
module "prometheus" {
    source = "github.com/CrowdStrike/terraform-modules/misc/prometheus"
    count = var.prometheus == true ? 1 : 0
    cloud = "gcp"
}