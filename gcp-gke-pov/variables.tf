# Provider Configuration
variable "credentials" {
  type = string
}
variable "project" {
  type = string
}
variable "region" {
  type = string
}
variable "zone" {
  type = string
}

# Optional Features
variable "autopilot" {
  type = bool
}
variable "bastion" {
  type = bool
}
variable "prometheus" {
  type = bool
}
variable "detection_container" {
  type = bool
}

# Infrastructure Configuration
variable "alias" {
  type = string
}
variable "private_subnet_cidr_1" {
  type = string
}
variable "private_subnet_cidr_2" {
  type = string
}
variable "private_subnet_cidr_3" {
  type = string
}
variable "public_subnet_cidr_1" {
  type = string
}
variable "public_subnet_cidr_2" {
  type = string
}
variable "public_subnet_cidr_3" {
  type = string
}

# GKE Configuration
variable "gke_num_nodes" {
  type = number
}

# Falcon Configuration
# Allowed Values: FalconNodeSensoror FalconContainer
# Falcon sensor type
# Allowed Values: FalconNodeSensoror FalconContainer
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
# Environment or 'Alias' tag
variable "environment" {
    description = "Environment or 'Alias' tag"
    default = "cs-pov"
    type = string
}