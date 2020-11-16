# vm name
stress_test_vm_name = "stresstest-vm"


# vm machine type
stress_test_vm_machine_type = "e2-medium"

# tags
stress_test_tags = ["http-lb"]

# vm start script
stress_test_vm_metadata_startup_script = "sudo apt-get -y install siege"

# boot disk Image for the instance to use
image_family  = "ubuntu-2010"
image_project = "ubuntu-os-cloud"

# forwarding rule name - used to obtain 
# external ip
forward_rule_name = "http-lb-ipv4"

# static ip addr name for stress_vm IP
ip_address_name = "ipv4-address"
# ip_addr region
ip_address_region = "us-west1"
# vm zone
stress_test_vm_zone = "us-west1-b"


# remote provisioning - connection type
type = "ssh"
# remote provisioning - user
user = "kawi.neal"
# remote provisioning - timeout
timeout = "120s"
# remote provisioning - private key file
stress_vm_key = "id_rsa"
