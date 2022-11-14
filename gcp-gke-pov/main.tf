module "network" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/gcp/network"
    
    alias  = var.alias
    region = var.region

    private-subnet-cidr-1 = var.private-subnet-cidr-1
    private-subnet-cidr-2 = var.private-subnet-cidr-2
    private-subnet-cidr-3 = var.private-subnet-cidr-3
    public-subnet-cidr-1  = var.public-subnet-cidr-1 
    public-subnet-cidr-2  = var.public-subnet-cidr-2 
    public-subnet-cidr-3  = var.public-subnet-cidr-3 
}

module "gke" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/gcp/gke"

    alias  = var.alias
    region = var.region

    gke-num-nodes = var.gke-num-nodes
    vpc-name  = module.network.network-name
    subnet-name   = module.network.private-subnet-1-name
}

module "bastion" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/gcp/bastion"
    count = var.bastion == true ? 1 : 0
}

module "prometheus" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/gcp/prometheus"
    count = var.prometheus == true ? 1 : 0
}

module "detection-container" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/gcp/detection-container"
    count = var.detection-container == true ? 1 : 0
}

module "falcon-operator" {
    source = "https://github.com/CrowdStrike/terraform-modules/tree/main/falcon/falcon-operator"
}