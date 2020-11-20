
output "vpc_network" {
  value       = module.network_vpc.network
  description = "URI of VPC created"
}

output "network_self_link" {
  value       = module.network_vpc.network_self_link
  description = "network self link"
}


output "subnets" {
  value       = module.network_vpc.subnets
  description = "network self link"
}


/*
  Output used for stress test VM
 Use output from network_subnet module to set  location 
 of stress_test_vm  : subnet, zone & ip address region
 */
output "eu_subnet" {
  value       = module.network_vpc.subnets["europe-west2/europe-west2"].self_link
  description = "europe-north network self link"
}


output "eu_ipaddr_region" {
  value       = module.network_vpc.subnets["europe-west2/europe-west2"].region
  description = "network self link"
}