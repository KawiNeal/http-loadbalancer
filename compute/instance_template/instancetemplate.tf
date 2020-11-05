resource "google_compute_instance_template" "webserver-template" {

  count = length(var.instance_templates)


  name         = var.instance_templates[count.index].name
  machine_type = var.instance_templates[count.index].template_machine_type

  region = var.instance_templates[count.index].region

  # Network interface
  network_interface {
    network    = var.instance_templates[count.index].network
    subnetwork = var.instance_templates[count.index].subnetwork

    access_config {

    }
  }

  # network tags
  tags = var.instance_templates[count.index].instancetemplate_tags

  disk {
    source_image = var.instance_templates[count.index].source_image
  }


  metadata_startup_script = var.startup_script

}