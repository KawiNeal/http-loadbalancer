resource "google_compute_region_autoscaler" "autoscaler" {

  # Count for list of group managers
  count = length(var.instance_group_mgrs)

  name   = var.instance_group_mgrs[count.index].name
  region = var.instance_group_mgrs[count.index].region

  target = var.instance_group_mgrs[count.index].self_link

  autoscaling_policy {
    min_replicas    = var.autoscaler_min_replicas
    max_replicas    = var.autoscaler_max_replicas
    cooldown_period = var.autoscaler_cooldown

    cpu_utilization {
      target = var.autoscaler_target_util
    }
  }

}