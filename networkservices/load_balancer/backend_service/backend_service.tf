resource "google_compute_backend_service" "backends" {

  name      = var.backend_name
  port_name = var.backend_portname
  project   = var.backend_project
  protocol  = var.backend_protocol

  health_checks = [var.backend_healthchecks]

  # backend block
  dynamic "backend" {
    for_each = var.backends
    content {
      balancing_mode        = backend.value["balance_mode"]
      capacity_scaler       = backend.value["capacity_scaler"]
      group                 = var.instance_group_mrgs[backend.key].instance_group
      max_rate_per_instance = backend.value["max_rate_per_instance"]
      max_utilization       = backend.value["max_utilization"]
    }
  }
}