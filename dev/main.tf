

# Terraform version
terraform {
  required_version = ">= 0.13"
}

# Use google provider
provider "google" {
  project     = var.project_id
  version     = "~> 3.46.0"
  credentials = file(var.gcp_auth_file)
}


#
module "network_subnet" {

  source = "../network/network_subnet"
  # VPC Subnet
  project_id  = var.project_id
  vpc         = var.vpc
  vpc_subnets = var.vpc_subnets

}


# get network & subnet data for reuse
data "google_compute_network" "network" {
  name = var.vpc

  depends_on = [module.network_subnet]
}
# get subnet[0] - useast1
data "google_compute_subnetwork" "subnet" {
  name   = var.vpc_subnets[0].subnet_name
  region = var.vpc_subnets[0].subnet_region

  depends_on = [module.network_subnet]
}

# Firewall rules
module "firewall_rule" {
  source = "../network/firewall_rule"
  # Inputs
  firewall_rules = var.firewall_rules

  depends_on = [module.network_subnet]
}

# Instance template
module "instancetemplate" {
  source = "../compute/instance_template"

  #Inputs
  instance_templates = var.instance_templates

  startup_script = file("${path.module}/../compute/instance_template/apache_startup.sh")

  depends_on = [module.network_subnet]
}



# Instance group manager
module "region_instance_group_mgr" {
  source = "../compute/region_instancegroupmgr"

  # Inputs
  group_mgr_names    = var.group_mgr_names
  group_mgr_regions  = var.group_mgr_regions
  instance_templates = module.instancetemplate.templates
  named_port         = var.named_port
  named_port_number  = var.named_port_number

}

# Instance group mgr autoscaler
module "autoscaler" {
  source = "../compute/auto_scaler"

  # Inputs
  instance_group_mgrs     = module.region_instance_group_mgr.instance_group_mgrs
  autoscaler_min_replicas = var.autoscaler_min_replicas
  autoscaler_max_replicas = var.autoscaler_max_replicas
  autoscaler_cooldown     = var.autoscaler_cooldown
  autoscaler_target_util  = var.autoscaler_target_util

}

# Health check - Use by Load Balancer
module "healthcheck" {
  source = "../networkservices/health_check"

  #Inputs
  healthcheck_name    = var.healthcheck_name
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold
  port                = var.port
  proxy_header        = var.proxy_header

}

# Backend service for Http Load Balancer
module "backend_service" {
  source = "../networkservices/load_balancer/backend_service"

  # Inputs
  backend_name         = var.backend_name
  backend_portname     = var.backend_portname
  backend_project      = var.project_id
  backend_protocol     = var.backend_protocol
  backend_healthchecks = module.healthcheck.id
  instance_group_mrgs  = module.region_instance_group_mgr.instance_group_mgrs
  backends             = var.backends

}

# URL map for http load balancer
module "url_map" {
  source = "../networkservices/load_balancer/url_map"

  # Inputs
  urlmap_name           = var.urlmap_name
  urlmap_project        = var.project_id
  urlmap_defaultservice = module.backend_service.id
}

# Http Proxy for http load balancer
module "http_proxy" {
  source = "../networkservices/load_balancer/target_proxy"

  # Inputs
  proxy_name    = var.proxy_name
  proxy_project = var.project_id
  url_map_id    = module.url_map.id
}

# Forwarding rules for http load balancer
module "fowarding_rule" {
  source = "../networkservices/load_balancer/forwarding_rule"

  # Inputs
  forwardingrule_project = var.project_id
  forwardingrule_target  = module.http_proxy.id
  forwarding_rules       = var.forwarding_rules
}


##################

/*
 Module to test Http LoadBalancer
 Switching subnet to US subnet or EU subnet 
 depending on where we want to create Stress test VM.
*/

# get subnet[1] - europewest1
data "google_compute_subnetwork" "eu_subnet" {
  name   = var.vpc_subnets[1].subnet_name
  region = var.vpc_subnets[1].subnet_region

  depends_on = [module.network_subnet]
}
# get subnet[2] - uswest1
data "google_compute_subnetwork" "us_subnet" {
  name   = var.vpc_subnets[2].subnet_name
  region = var.vpc_subnets[2].subnet_region

  depends_on = [module.network_subnet]
}

# dev test http loadbalancer
module "dev_test" {
  source = "../test/dev/stress_test_vm"

  # Inputs
  stress_test_vm_name = var.stress_test_vm_name

  stress_test_vm_zone                    = var.stress_test_vm_zone
  stress_test_vm_machine_type            = var.stress_test_vm_machine_type
  stress_test_tags                       = var.stress_test_tags
  stress_test_vm_metadata_startup_script = var.stress_test_vm_metadata_startup_script

  stress_test_network = module.network_subnet.network_self_link
  stress_test_subnet  = data.google_compute_subnetwork.us_subnet.self_link

  forward_rule_name = var.forward_rule_name

  image_family = var.image_family
  image_project = var.image_project

  ip_address_name   = var.ip_address_name
  ip_address_region = var.ip_address_region
  type              = var.type
  user              = var.user
  timeout           = var.timeout
  stress_vm_key     = var.stress_vm_key

  depends_on = [module.fowarding_rule, module.backend_service]
}
