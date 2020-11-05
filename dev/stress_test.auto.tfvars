# vm name
stress_test_vm_name = "siege-vm"




# vm machine type
stress_test_vm_machine_type = "f1-micro"

# tags
stress_test_tags = ["http-server"]

# vm start script
stress_test_vm_metadata_startup_script = "sudo apt-get -y install siege"

# boot disk Image for the instance to use
stress_test_vm_image = "debian-cloud/debian-10"

# forwarding rule name - used to obtain 
# external ip
forward_rule_name = "http-lb-ipv4"

# static ip addr name for stress_vm IP
ip_address_name = "ipv4-address"
# ip_addr region
ip_address_region = "europe-west1"
# vm zone
stress_test_vm_zone = "europe-west1-b"


# remote provisioing - connection type
type = "ssh"
# remote provisioning - user
user = "kawi_neal"
# remote provisioning - timeout
timeout = "500s"
# remote proprovisioning - private key file
stress_vm_key = "stress_vm_key"
