# Provider Configuration
variable "project" {
  type = string
}
variable "region" {
  type = string
}

# Optional Features
variable "autopilot" {
  type = bool
  default = false
}
variable "prometheus" {
  type = bool
  default = false
}
variable "detection_container" {
  type = bool
  default = false
}

# Infrastructure Configuration
variable "alias" {
  type = string
}
variable "subnet_cidr_1" {
  type = string
  default = "10.0.1.0/24"
}
variable "subnet_cidr_2" {
  type = string
  default = "10.0.2.0/24"
}
variable "subnet_cidr_3" {
  type = string
  default = "10.0.3.0/24"
}

# GKE Configuration
variable "gke_num_nodes" {
  type = number
  default = 1
}
variable "cluster_name" {
  type = string
}
# Allowed Values: UBUNTU_CONTAINERD or COS_CONTAINERD
# If you choose COS_CONTAINERD, sensor_type must = FalconContainer
variable "node_os" {
  type = string
  default = "UBUNTU_CONTAINERD"
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