
module "aks" {
    source             = "github.com/CrowdStrike/terraform-modules/azure/aks"
    alias              = var.alias
    location           = var.location
    resource_group     = var.resource_group
    cluster_name       = var.cluster_name
    kubernetes_version = var.kubernetes_version
    aks_num_nodes      = var.aks_num_nodes
    aks_min_nodes      = var.aks_min_nodes
    aks_max_nodes      = var.aks_max_nodes
    node_vm_size       = var.node_vm_size
    os_sku             = var.os_sku
}

module "falcon" {
    source        = "github.com/CrowdStrike/terraform-modules/falcon/operator"
    client_id     = var.client_id
    client_secret = var.client_secret
    sensor_type   = var.sensor_type
    environment   = var.alias
}

module "protection_agent" {
    source                  = "github.com/CrowdStrike/terraform-modules/falcon/k8s-protection-agent"
    falcon_client_id = var.client_id
    falcon_client_secret = var.client_secret
    cluster_name = "${var.alias}-${var.cluster_name}"
    falcon_docker_api_token = var.docker_token
    falcon_cid = var.cid
    falcon_env = var.crowdstrike_cloud
}

module "detection_container" {
    source = "github.com/CrowdStrike/terraform-modules/falcon/detection-container"
    count  = var.detection_container == true ? 1 : 0
}
    
module "prometheus" {
    source = "github.com/CrowdStrike/terraform-modules/misc/prometheus"    
    count  = var.prometheus == true ? 1 : 0
    cloud  = "gcp"
}
