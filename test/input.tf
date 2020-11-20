# vm name
variable "stress_test_vm_name" {}

# vm zone
variable "stress_test_vm_zone" {}
# vm machine type
variable "stress_test_vm_machine_type" {}
# vm associated tags
variable "stress_test_tags" {}
# vm start script
variable "stress_test_vm_metadata_startup_script" {}

# vm network
variable "stress_test_network" {}
# vm subnet
variable "stress_test_subnet" {}

# forwarding rule name - used to obtain 
# external ip
variable "forward_rule_name" {}

# vm disk image family
variable "image_family" {}
# vm disk image project
variable "image_project" {}

# static ip addr name for stress_vm IP
variable "ip_address_name" {}
# ip_addr region
variable "ip_address_region" {}


# remote provisioing - connection type
variable "type" {}
# remote provisioning - user
variable "user" {}
# remote provisioning - timeout
variable "timeout" {}
# remote provisioning - private key file
variable "stress_vm_key" {}

