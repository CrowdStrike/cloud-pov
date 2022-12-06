variable "resource_group" {
  type = string
}
variable "alias" {
  type = string
}
variable "location" {
  type = string
}

# AKS Configuration

variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type = string
  default = "1.23.12"
}
variable "aks_num_nodes" {
  type = number
  default = 1
}
variable "aks_min_nodes" {
  type = number
  default = 1
}
variable "aks_max_nodes" {
  type = number
  default = 1
}
variable "node_vm_size" {
  type = string
  default = "Standard_B4ms"
}
variable "os_sku" {
  type = string
  default = "Ubuntu"
}

# Falcon sensor type
# Allowed Values: FalconNodeSensor or FalconContainer
variable "sensor_type" {
    type = string
    default = "FalconNodeSensor"
    description = "Falcon sensor type: FalconNodeSensor or FalconContainer"

    validation {
        condition = contains(["FalconNodeSensor", "FalconContainer"], var.sensor_type)
        error_message = "Sensor type must be FalconNodeSensor or FalconContainer"
    }

}

# Falcon credentials
variable "client_id" {
    type = string
    description = "Falcon API Client ID"
    sensitive = true
}
variable "client_secret" {
    type = string
    description = "Falcon API Client Secret"
    sensitive = true
}
variable "cid" {
    type = string
    description = "Falcon CID"
    sensitive = true
}
variable "crowdstrike_cloud" {
    type = string
    description = "Falcon Cloud"
    sensitive = true
}
variable "docker_token" {
    type = string
    description = "Falcon Docker API Token"
    sensitive = true
}

# Optional Features
variable "prometheus" {
  type = bool
  default = false
}
variable "detection_container" {
  type = bool
  default = false
}