
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
