terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.41.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "kubectl" {
  host                   = module.gke.cluster-endpoint
  cluster_ca_certificate = base64decode(module.gke.cluster-ca-certificate)
  token = module.gke.gke-token
  load_config_file       = false
}