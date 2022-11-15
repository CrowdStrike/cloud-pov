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
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.7.1"
    }
  }
}

data "google_client_config" "default" {
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "kubectl" {
  host                   = module.gke.cluster_endpoint
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token = module.gke.gke_token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}