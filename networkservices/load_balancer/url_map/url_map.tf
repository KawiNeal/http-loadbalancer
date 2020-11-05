resource "google_compute_url_map" "url_map" {

  name    = var.urlmap_name
  project = var.urlmap_project

  default_service = var.urlmap_defaultservice

}