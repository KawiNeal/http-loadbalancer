terraform {
  backend "gcs" {
    bucket      = "http-loadbalancer"
    prefix      = "dev"
    credentials = "http-loadbalancer.json"
  }
}