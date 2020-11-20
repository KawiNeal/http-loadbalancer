# Module uses public module registry
# to create network/subnet
module "network_subnet" {
  source = "../network/network_subnet"
  # VPC Subnet
  project_id  = var.project_id
  vpc         = var.vpc
  vpc_subnets = var.vpc_subnets

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


# dev test http loadbalancer
module "test" {
  source = "../test"

  # Inputs
  stress_test_vm_name = var.stress_test_vm_name
  stress_test_network = module.network_subnet.network_self_link

  # Use output from network_subnet module to set  location 
  # of stress_test_vm  : subnet, zone & ip address region
  # For testing will default to europewest2  zone B per output
  stress_test_subnet  = module.network_subnet.eu_subnet
  ip_address_region   = module.network_subnet.eu_ipaddr_region
  stress_test_vm_zone = join("", [module.network_subnet.eu_ipaddr_region, "-b"])

  stress_test_vm_machine_type            = var.stress_test_vm_machine_type
  stress_test_tags                       = var.stress_test_tags
  stress_test_vm_metadata_startup_script = var.stress_test_vm_metadata_startup_script
  forward_rule_name                      = var.forward_rule_name
  image_family                           = var.image_family
  image_project                          = var.image_project
  ip_address_name                        = var.ip_address_name
  type                                   = var.type
  user                                   = var.user
  timeout                                = var.timeout
  stress_vm_key                          = var.stress_vm_key

  depends_on = [module.network_subnet, module.fowarding_rule]
}
