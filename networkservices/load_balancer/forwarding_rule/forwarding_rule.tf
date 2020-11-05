resource "google_compute_global_forwarding_rule" "http" {

  # Count for list of group managers
  count = length(var.forwarding_rules)

  project = var.forwardingrule_project
  target  = var.forwardingrule_target

  name                  = var.forwarding_rules[count.index].forwardingrule_name
  ip_protocol           = var.forwarding_rules[count.index].forwardingrule_protocol
  ip_version            = var.forwarding_rules[count.index].ip_version
  load_balancing_scheme = var.forwarding_rules[count.index].load_balancing_scheme
  port_range            = var.forwarding_rules[count.index].port_range

}
