# PROJECT VARS
# Project Id 
project_id = "http-loadbalancer"
# GCP authentication file
gcp_auth_file = "http-loadbalancer.json"


# VPC-SUBNET inputs - Creates VPC & subnets
vpc = "http-lb"
vpc_subnets = [
  { subnet_name = "us-east1", subnet_ip = "10.210.0.0/20", subnet_region = "us-east1" },
  { subnet_name = "europe-west1", subnet_ip = "10.214.0.0/20", subnet_region = "europe-west1" },
  { subnet_name = "us-west1", subnet_ip = "10.218.0.0/20", subnet_region = "us-west1" }
]


# Firewall rules inputs
firewall_rules = [
  { firewall_network       = "http-lb", firewall_name = "httplb-allow-http", firewall_ports = ["80"], firewall_protocol = "tcp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-lb"], firewall_priority = 65534
  },
  { firewall_network       = "http-lb", firewall_name = "httplb-allow-health-check", firewall_ports = ["80"], firewall_protocol = "tcp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-lb-mig"], firewall_priority = 65534
  },
  { firewall_network       = "http-lb", firewall_name = "httplb-allow-ssh", firewall_ports = ["22"], firewall_protocol = "tcp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-lb"], firewall_priority = 65534
  },
  { firewall_network       = "http-lb", firewall_name = "httplb-allow-icmp", firewall_ports = [], firewall_protocol = "icmp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-lb"], firewall_priority = 65534
  }

]

# Instance Template variables
instance_templates = [
  { name                  = "us-east1-template", network = "http-lb", region = "us-east1", subnetwork = "us-east1", template_machine_type = "f1-micro",
    instancetemplate_tags = ["http-server","http-lb-mig"], source_image = "debian-cloud/debian-9"
  },
  { name                  = "europe-west1-template", network = "http-lb", region = "europe-west1", subnetwork = "europe-west1", template_machine_type = "f1-micro",
    instancetemplate_tags = ["http-server","http-lb-mig"], source_image = "debian-cloud/debian-9"
  }
]

# instance group manager & autoscaler ###
group_mgr_names         = ["us-east1-mig", "europe-west1-mig"]
group_mgr_regions       = ["us-east1", "europe-west1"]
named_port              = "http"
named_port_number       = 80
autoscaler_min_replicas = 1
autoscaler_max_replicas = 6
autoscaler_cooldown     = 45
autoscaler_target_util  = 0.4


# health check - tcp
healthcheck_name    = "http-lb-health-check"
check_interval_sec  = 10
healthy_threshold   = 1
timeout_sec         = 5
unhealthy_threshold = 3
port                = 80
proxy_header        = "NONE"



# backend_service for load balancer
backend_name     = "http-lb-backend"
backend_portname = "http"
backend_protocol = "HTTP"
backends = [
  { balance_mode = "RATE", capacity_scaler = 1, max_rate_per_instance = 50, max_utilization = 0.8 },
  { balance_mode = "UTILIZATION", capacity_scaler = 1, max_rate_per_instance = 0, max_utilization = 0.8 }
]

# url map 
urlmap_name = "http-lb"

# http proxy 
proxy_name = "http-lb-proxy"

# forward rules
forwarding_rules = [
  { forwardingrule_name = "http-lb-ipv4", forwardingrule_protocol = "TCP", ip_version = "IPV4"
  load_balancing_scheme = "EXTERNAL", port_range = "80" },

  { forwardingrule_name = "http-lb-ipv6", forwardingrule_protocol = "TCP", ip_version = "IPV6"
  load_balancing_scheme = "EXTERNAL", port_range = "80" }
]

