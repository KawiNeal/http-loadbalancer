# For DEV environment define :
# Terraform version , required GCP provider & remote backend
terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

  backend "gcs" {
    bucket      = "http-loadbalancer-temp"
    prefix      = "dev"
    credentials = "http-loadbalancer-copy-3a4996aec9f6.json"
  }
}
# Use google provider
provider "google" {
  project     = var.project_id
  version     = "~> 3.46.0"
  credentials = file(var.gcp_auth_file)
}

###########################


# GCP authentication file
variable "gcp_auth_file" {
  type = string
}

# Project
variable "project_id" {
  type = string
}

###################

# VPC & Subnet input variables
variable "vpc" {
  type = string
}
variable "vpc_subnets" {
  type = list(object({ subnet_name = string, subnet_ip = string, subnet_region = string }))
}

####################

## Firewall variable object
variable "firewall_rules" {
  type = list(object({ firewall_network = string, firewall_name = string, firewall_ports = list(string), firewall_protocol = string,
  firewall_source_ranges = list(string), firewall_target_tags = list(string), firewall_priority = number }))
}

####################

## Instance templates variable object 
variable "instance_templates" {
  type = list(object({ name = string, network = string, region = string, subnetwork = string, template_machine_type = string,
  instancetemplate_tags = list(string), source_image = string, source_image = string }))
}

####################

## Instance group manager & Autoscaler

# group managers
variable "group_mgr_names" {
  type = list(string)
}
# group mananger regions
variable "group_mgr_regions" {
  type = list(string)
}
# named port
variable "named_port" {
  type = string
}
# named port number
variable "named_port_number" {
  type = number
}
# Autoscaler
# min replicas
variable "autoscaler_min_replicas" {
  type = number
}
# max replicas
variable "autoscaler_max_replicas" {
  type = number
}
# cool down period
variable "autoscaler_cooldown" {
  type = number
}
# target utilization
variable "autoscaler_target_util" {
  type = number
}

####################

## Health check variables
variable healthcheck_name {
  type = string
}
variable check_interval_sec {
  type = number
}
variable healthy_threshold {
  type = number
}
variable timeout_sec {
  type = number
}
variable unhealthy_threshold {
  type = number
}
variable port {
  type = number
}
variable proxy_header {
  type = string
}


####################
## Backend Service variables

# backend service name
variable backend_name {
  type = string
}
# Back end port name
variable backend_portname {
  type = string
}
# backend protocal 
variable backend_protocol {
  type = string
}

# backend list 
variable backends {
  description = "Set of Backends that service this BackEndService."
  type = list(object({
    balance_mode          = string
    capacity_scaler       = number
    max_rate_per_instance = number
    max_utilization       = number
    })
  )
}

####################

## URL map variables
variable urlmap_name {
  type = string
}

####################

## proxy map variables
# proxy name
variable proxy_name {
  type = string
}


####################
# forwarding rules variables

# fowarding rules object
variable forwarding_rules {
  description = "Set of Backends that service this BackEndService."
  type = list(object({
    forwardingrule_name     = string
    forwardingrule_protocol = string
    ip_version              = string
    load_balancing_scheme   = string
    port_range              = string
    })
  )
}

#################################################
# Stress Test VM Variables
#
#################################################
# vm name
variable stress_test_vm_name {
  type = string
}

# vm machine type
variable stress_test_vm_machine_type {
  type = string
}
# tags
variable stress_test_tags {
  type = list(string)
}
# vm start script
variable stress_test_vm_metadata_startup_script {
  type = string
}
# forwarding rule name - used to obtain external ip
variable forward_rule_name {
  type = string
}
# vm disk image family
variable image_family {
  type = string
}
# vm disk image project
variable image_project {
  type = string
}
# static ip addr name for stress_vm IP
variable ip_address_name {
  type = string
}
# remote provisioing - connection type
variable type {
  type = string
}
# remote provisioning - user
variable user {
  type = string
}
# remote provisioning - timeout
variable timeout {
  type = string
}
# remote proprovisioning - private key file
variable stress_vm_key {
  type = string
}
