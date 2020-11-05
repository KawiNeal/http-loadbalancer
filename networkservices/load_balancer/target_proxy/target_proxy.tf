resource "google_compute_target_http_proxy" "proxy" {

  name    = var.proxy_name
  project = var.proxy_project

  url_map = var.url_map_id
}