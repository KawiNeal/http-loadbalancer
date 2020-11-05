# PROJECT VARS
# Project Id 
project_id = "https-lb-gcp-registry"
# GCP authentication file
gcp_auth_file = "https-lb-gcp-registry-63f84a98ca43.json"


# VPC-SUBNET inputs - Creates VPC & subnets
vpc = "http-lb"
vpc_subnets = [
  { subnet_name = "us-east1", subnet_ip = "10.210.0.0/20", subnet_region = "us-east1" },
  { subnet_name = "europe-west1", subnet_ip = "10.214.0.0/20", subnet_region = "europe-west1" },
  { subnet_name = "us-west1", subnet_ip = "10.218.0.0/20", subnet_region = "us-west1" }

]


# Firewall rules inputs
firewall_rules = [
  { firewall_network       = "http-lb", firewall_name = "default-allow-http", firewall_ports = ["80"], firewall_protocol = "tcp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-server"], firewall_priority = 65534
  },
  { firewall_network       = "http-lb", firewall_name = "default-allow-health-check", firewall_ports = [], firewall_protocol = "tcp",
    firewall_source_ranges = ["10.210.0.0/20", "10.214.0.0/20"], firewall_target_tags = ["http-server"], firewall_priority = 65534
  },
  { firewall_network       = "http-lb", firewall_name = "default-allow-ssh-mig", firewall_ports = ["22"], firewall_protocol = "tcp",
    firewall_source_ranges = ["0.0.0.0/0"], firewall_target_tags = ["http-server"], firewall_priority = 65534
  }

]

# Instance Template variables
instance_templates = [
  { name                  = "us-east1-template", network = "http-lb", region = "us-east1", subnetwork = "us-east1", template_machine_type = "f1-micro",
    instancetemplate_tags = ["http-server"], source_image = "debian-cloud/debian-9"
  },
  { name                  = "europe-west1-template", network = "http-lb", region = "europe-west1", subnetwork = "europe-west1", template_machine_type = "f1-micro",
    instancetemplate_tags = ["http-server"], source_image = "debian-cloud/debian-9"
  }
]

# instance group manager & autoscaler ###
group_mgr_names         = ["us-east1-mig", "europe-west1-mig"]
group_mgr_regions       = ["us-east1", "europe-west1"]
target_size             = 1
autoscaler_min_replicas = 1
autoscaler_max_replicas = 5
autoscaler_cooldown     = 45
autoscaler_target_util  = 0.8


# health check - tcp
healthcheck_name    = "http-lb-health-check"
check_interval_sec  = 10
healthy_threshold   = 2
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

###########################


# Cloud router inputs - 
cloudrouter_name   = "nat-router"
cloudrouter_region = "us-east1"

#
# VM_INSTANCE variables
#
vm_name                 = "webserver"
subnet                  = "us-east1"
vm_zone                 = "us-east1-b"
machine_type            = "f1-micro"
tags                    = ["allow-health-checks", "default-allow-ssh"]
auto_delete             = "false"
metadata_startup_script = "sudo apt-get update;sudo apt-get install -y apache2;sudo service apache2 start"
image                   = "debian-cloud/debian-10"

