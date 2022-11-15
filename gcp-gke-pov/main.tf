module "network" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/gcp/network"
    
    alias  = var.alias
    region = var.region

    private_subnet_cidr_1 = var.private_subnet_cidr_1
    private_subnet_cidr_2 = var.private_subnet_cidr_2
    private_subnet_cidr_3 = var.private_subnet_cidr_3
    public_subnet_cidr_1  = var.public_subnet_cidr_1 
    public_subnet_cidr_2  = var.public_subnet_cidr_2 
    public_subnet_cidr_3  = var.public_subnet_cidr_3 
}

module "gke" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/gcp/gke"

    alias  = var.alias
    region = var.region

    gke_num_nodes = var.gke_num_nodes
    vpc_name  = module.network.network_name
    subnet_name   = module.network.private_subnet_1_name
}

module "bastion" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/gcp/bastion"
    count = var.bastion == true ? 1 : 0
}

module "prometheus" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/gcp/prometheus"
    count = var.prometheus == true ? 1 : 0
}

module "detection_container" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/gcp/detection-container"
    count = var.detection_container == true ? 1 : 0
}

module "falcon" {
    source = "/Users/ffalor/github.com/ffalor/terraform-modules/falcon/operator"
    client_id = var.client_id
    client_secret = var.client_secret
    sensor_type = var.sensor_type
    environment = var.environment
}