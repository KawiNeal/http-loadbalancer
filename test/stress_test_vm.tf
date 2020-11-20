#
#   Stress Test VM Instance
#

# get forward rule to obtain frontend IP
data "google_compute_global_forwarding_rule" "http" {
  name = var.forward_rule_name

}

# image disk for vm
data "google_compute_image" "vm_image" {
  family  = var.image_family
  project = var.image_project
}

# create static ip address for test_vm
resource "google_compute_address" "static" {
  name   = var.ip_address_name
  region = var.ip_address_region
}

# Create test vm with external static ip
resource "google_compute_instance" "stress_test_vm" {
  name = var.stress_test_vm_name

  zone = var.stress_test_vm_zone

  machine_type = var.stress_test_vm_machine_type
  tags         = var.stress_test_tags

  metadata_startup_script = var.stress_test_vm_metadata_startup_script

  boot_disk {
    initialize_params {
      image = data.google_compute_image.vm_image.self_link
    }

  }

  # Network interface
  network_interface {
    network    = var.stress_test_network
    subnetwork = var.stress_test_subnet

    access_config {
      # test_vm static ip address
      nat_ip = google_compute_address.static.address
    }

  }

  # SSH to stress_test VM and run siege (900 sec)
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = var.type
      user        = var.user
      timeout     = var.timeout
      private_key = file(var.stress_vm_key)
    }

    # pause 20 before running siege
    inline = [
      "sleep 360",
      "siege -c 255 -t580 http://${data.google_compute_global_forwarding_rule.http.ip_address} &",
      "sleep 600"
    ]

  }

  # On terraform instance - output external IP address siege sending requests.
  provisioner "local-exec" {
    command = "echo ${data.google_compute_global_forwarding_rule.http.ip_address} >> ip_addr_frontend.txt"
  }


  # ensure ip addr in place before SSH
  depends_on = [google_compute_address.static]

}
