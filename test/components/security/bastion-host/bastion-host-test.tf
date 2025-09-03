provider "alicloud" {
  region = "cn-hangzhou"
}

variable "ssh_rule_port_range" {
  description = "SSH rule port range"
  type        = string
  default     = "22/22"
}

variable "https_rule_port_range" {
  description = "HTTPS rule port range"
  type        = string
  default     = "443/443"
}

variable "ssh_rule_cidr_ip" {
  description = "SSH rule CIDR IP"
  type        = string
  default     = "0.0.0.0/0"
}

variable "https_rule_cidr_ip" {
  description = "HTTPS rule CIDR IP"
  type        = string
  default     = "0.0.0.0/0"
}

module "bastion_host" {
  source = "../../../../components/security/bastion-host"

  create_bastion_host        = true
  availability_zone          = "cn-hangzhou-k"
  bastion_host_instance_name = "tf-bastion-host-test"
  vpc_cidr                   = "10.0.0.0/8"
  vswitch_cidr               = "10.0.0.0/24"
  security_group_name        = "bastion-host-sg"
  security_group_description = "Security group for Bastion Host"
  
  # bastion host instance variables
  bastion_host_description  = "Test Bastion Host"
  bastion_host_license_code = "bhah_ent_50_asset"

  # Custom security group rule variables
  ssh_rule_port_range = var.ssh_rule_port_range
  https_rule_port_range = var.https_rule_port_range
  ssh_rule_cidr_ip = var.ssh_rule_cidr_ip
  https_rule_cidr_ip = var.https_rule_cidr_ip

  create_vpc_resources       = true
}

output "bastion_host_id" {
  description = "The ID of the bastion host instance"
  value       = module.bastion_host.bastion_host_instance_id
}

output "bastion_host_vpc_id" {
  description = "The ID of the VPC"
  value       = module.bastion_host.bastion_host_vpc_id
}

output "bastion_host_vswitch_id" {
  description = "The ID of the VSwitch"
  value       = module.bastion_host.bastion_host_vswitch_id
}

output "bastion_host_security_group_id" {
  description = "The ID of the security group"
  value       = module.bastion_host.bastion_host_security_group_id
}