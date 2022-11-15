module "network" {
    source = "../../../crowdstrike/terraform-modules/gcp/network"
    
    alias  = var.alias
    region = var.region

    subnet_cidr_1 = var.subnet_cidr_1
    subnet_cidr_2 = var.subnet_cidr_2
    subnet_cidr_3 = var.subnet_cidr_3
}

module "gke" {
    source = "../../../crowdstrike/terraform-modules/gcp/gke"
    cluster_name = var.cluster_name
    alias  = var.alias
    region = var.region
    
    gke_num_nodes = var.gke_num_nodes
    node_os = var.node_os
    vpc_name  = module.network.network_name
    subnet_name   = module.network.subnet_1_name
}

module "falcon" {
    source = "../../../crowdstrike/terraform-modules/falcon/operator"
    client_id = var.client_id
    client_secret = var.client_secret
    sensor_type = var.sensor_type
    environment = var.alias
}

module "protection_agent" {
    source = "../../../crowdstrike/terraform-modules/falcon/k8s-protection-agent"
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
    source = "../../../crowdstrike/terraform-modules/falcon/detection-container"
    count = var.detection_container == true ? 1 : 0
}