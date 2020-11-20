resource "google_compute_region_instance_group_manager" "appserver" {

  # Count for list of group managers
  count = length(var.group_mgr_names)

  name               = element(var.group_mgr_names, count.index)
  base_instance_name = element(var.group_mgr_names, count.index)
  region             = element(var.group_mgr_regions, count.index)

  # version
  version {
    instance_template = var.instance_templates[count.index].self_link
  }

  named_port {
    name = var.named_port
    port = var.named_port_number
  }


}

