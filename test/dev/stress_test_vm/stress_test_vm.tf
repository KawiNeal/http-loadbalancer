#
#   Stress Test VM Instance
#

# get forward rule to obtain frontend IP
data "google_compute_global_forwarding_rule" "http" {
  name = var.forward_rule_name

}

resource "google_compute_address" "static" {
  name   = var.ip_address_name
  region = var.ip_address_region
}

resource "google_compute_instance" "stress_test_vm" {
  name = var.stress_test_vm_name

  zone = var.stress_test_vm_zone

  machine_type = var.stress_test_vm_machine_type
  tags         = var.stress_test_tags

  metadata_startup_script = var.stress_test_vm_metadata_startup_script

  boot_disk {
    initialize_params {
      image = var.stress_test_vm_image
    }

  }

  # Network interface
  network_interface {
    network    = var.stress_test_network
    subnetwork = var.stress_test_subnet

    access_config {
      nat_ip = google_compute_address.static.address
    }

  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = var.type
      user        = var.user
      timeout     = var.timeout
      private_key = file(var.stress_vm_key)
    }

    inline = [
      "siege -c 250 http://${data.google_compute_global_forwarding_rule.http.ip_address} &",
      "sleep 300"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${data.google_compute_global_forwarding_rule.http.ip_address} >> ip_addr_frontend.txt"
  }

}
