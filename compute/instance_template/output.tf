output "templates" {
  value       = google_compute_instance_template.webserver-template
  description = "Instance templates created"
}