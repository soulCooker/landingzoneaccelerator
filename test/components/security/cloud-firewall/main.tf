provider "alicloud" {
  region = "cn-hangzhou"
}

module "cloud_firewall" {
  source = "../../../../components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  
  cloud_firewall_instance_type   = "payg_version"
  cloud_firewall_instance_name   = "tf-test-firewall"
  cloud_firewall_bandwidth       = 100
  cloud_firewall_payment_type    = "PayAsYouGo"

  member_account_ids = []

  control_policy_application_name     = "ANY"
  control_policy_source_type          = "net"
  control_policy_destination_type     = "net"

  internet_acl_rules = [
    {
      description         = "Allow HTTP traffic"
      source_cidr         = "0.0.0.0/0"
      destination_cidr    = "0.0.0.0/0"
      ip_protocol         = "TCP"
      source_port         = "80"
      destination_port    = "80"
      policy              = "accept"
      direction           = "in"
      priority            = 100
    },
    {
      description         = "Allow HTTPS traffic"
      source_cidr         = "0.0.0.0/0"
      destination_cidr    = "0.0.0.0/0"
      ip_protocol         = "TCP"
      source_port         = "443"
      destination_port    = "443"
      policy              = "accept"
      direction           = "in"
      priority            = 110
    }
  ]

  nat_acl_rules = [
    {
      description         = "Allow SSH traffic"
      source_cidr         = "10.0.0.0/8"
      destination_cidr    = "0.0.0.0/0"
      ip_protocol         = "TCP"
      source_port         = "22"
      destination_port    = "22"
      policy              = "accept"
      direction           = "in"
      priority            = 200
    }
  ]

  vpc_acl_rules = [
    {
      description         = "Allow internal traffic"
      source_cidr         = "10.0.0.0/8"
      destination_cidr    = "10.0.0.0/8"
      ip_protocol         = "ANY"
      source_port         = "1/65535"
      destination_port    = "1/65535"
      policy              = "accept"
      direction           = "in"
      priority            = 300
    }
  ]
  
  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}

output "cloud_firewall_instance_id" {
  description = "The ID of the cloud firewall instance"
  value       = module.cloud_firewall.cloud_firewall_instance_id
}

output "cloud_firewall_instance_status" {
  description = "The status of the cloud firewall instance"
  value       = module.cloud_firewall.cloud_firewall_instance_status
}

output "member_account_ids" {
  description = "The list of member account IDs managed by the cloud firewall"
  value       = module.cloud_firewall.member_account_ids
}

output "internet_acl_rule_count" {
  description = "The number of internet ACL rules created"
  value       = module.cloud_firewall.internet_acl_rule_count
}

output "nat_acl_rule_count" {
  description = "The number of NAT ACL rules created"
  value       = module.cloud_firewall.nat_acl_rule_count
}

output "vpc_acl_rule_count" {
  description = "The number of VPC ACL rules created"
  value       = module.cloud_firewall.vpc_acl_rule_count
}