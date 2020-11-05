

# Set up GCP provider
terraform {
  required_version = ">= 0.13"
}

# Use google provider
provider "google" {
  project = var.project_id
  #version = "3.5.0"
  version     = "~> 3.43.0"
  credentials = file(var.gcp_auth_file)
}
