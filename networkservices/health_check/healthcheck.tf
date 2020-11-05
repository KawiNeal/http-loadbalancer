resource "google_compute_health_check" "healthcheck" {

  name                = var.healthcheck_name
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold

  tcp_health_check {
    port         = var.port
    proxy_header = var.proxy_header
  }
}
