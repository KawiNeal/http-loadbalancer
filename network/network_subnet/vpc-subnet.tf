module "network_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "2.5.0"
  # insert the 2 required variables here

  project_id   = var.project_id
  network_name = var.vpc
  subnets      = var.vpc_subnets

}

