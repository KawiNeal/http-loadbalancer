# vm name
variable stress_test_vm_name {
  type = string
}

# vm zone
variable stress_test_vm_zone {
  type = string
}
# vm machine type
variable stress_test_vm_machine_type {
  type = string
}
# tags
variable stress_test_tags {
  type = list(string)
}
# vm start script
variable stress_test_vm_metadata_startup_script {
  type = string
}
# boot disk Image for the instance to use
variable stress_test_vm_image {
  type = string
}

# forwarding rule name - used to obtain 
# external ip
variable forward_rule_name {
  type = string
}

# static ip addr name for stress_vm IP
variable ip_address_name {
  type = string
}
# ip_addr region
variable ip_address_region {
  type = string
}

# remote provisioing - connection type
variable type {
  type = string
}
# remote provisioning - user
variable user {
  type = string
}
# remote provisioning - timeout
variable timeout {
  type = string
}
# remote proprovisioning - private key file
variable stress_vm_key {
  type = string
}
