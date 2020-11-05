
resource "google_compute_firewall" "firewall_rules" {

  # Get count for firewall rules to create
  count = length(var.firewall_rules)

  # Firewall rule network - Single network for all firewall rules
  network = var.firewall_rules[count.index].firewall_network

  name = var.firewall_rules[count.index].firewall_name
  # Protocals & ports
  allow {
    protocol = var.firewall_rules[count.index].firewall_protocol
    ports    = var.firewall_rules[count.index].firewall_ports
  }
  # Source CIDR ranges
  source_ranges = var.firewall_rules[count.index].firewall_source_ranges
  # Target tags
  target_tags = var.firewall_rules[count.index].firewall_target_tags

  # Priority
  priority = var.firewall_rules[count.index].firewall_priority

}