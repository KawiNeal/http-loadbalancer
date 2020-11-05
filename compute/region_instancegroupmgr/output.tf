output "instance_group_mgrs" {
  value       = google_compute_region_instance_group_manager.appserver
  description = "Instance managers created"
}