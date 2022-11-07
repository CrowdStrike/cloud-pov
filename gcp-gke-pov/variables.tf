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
variable "detection-container" {
  type = bool
}

# Infrastructure Configuration
variable "alias" {
  type = string
}
variable "private-subnet-cidr-1" {
  type = string
}
variable "private-subnet-cidr-2" {
  type = string
}
variable "private-subnet-cidr-3" {
  type = string
}
variable "public-subnet-cidr-1" {
  type = string
}
variable "public-subnet-cidr-2" {
  type = string
}
variable "public-subnet-cidr-3" {
  type = string
}

# GKE Configuration

variable "gke-num-nodes" {
  type = number
}