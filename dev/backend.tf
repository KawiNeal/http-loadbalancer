terraform {
  backend "gcs" {
    bucket      = "tf-state-https-lb-gcp-registry"
    prefix      = "dev"
    credentials = "https-lb-gcp-registry-63f84a98ca43.json"
  }
}