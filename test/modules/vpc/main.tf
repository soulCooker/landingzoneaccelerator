provider "alicloud" {
  region = "cn-hangzhou"
}

module "vpc" {
  source = "../../../modules/vpc"

  vpc_name        = "example-vpc"
  vpc_cidr        = "192.168.0.0/27"
  vpc_description = "Example VPC for testing."
  vpc_tags = {
    env     = "test"
  }

  enable_ipv6       = false
  ipv6_isp          = "BGP"
  resource_group_id = null
  user_cidrs        = ["30.0.0.0/8"]

  ipv4_cidr_mask    = 27
  ipv4_ipam_pool_id = null
  ipv6_cidr_block   = null

  vswitches = [
    {
      vswitch_name = "example-vswitch-1"
      cidr_block   = "192.168.0.0/28"
      zone_id      = "cn-hangzhou-h"
      description  = "Test vswitch 1"
      enable_ipv6  = false
      ipv6_cidr_block_mask = null
      tags = { env = "test" }
    },
    {
      vswitch_name = "example-vswitch-2"
      cidr_block   = "192.168.0.16/28"
      zone_id      = "cn-hangzhou-i"
    }
  ]

  enable_acl      = true
  acl_name        = "example-acl"
  acl_description = "Example ACL for testing."
  acl_tags        = { env = "test" }

  ingress_acl_entries = [
    {
      protocol               = "tcp"
      port                   = "80/80"
      source_cidr_ip         = "0.0.0.0/0"
      policy                 = "accept"
      description            = "Allow HTTP"
      network_acl_entry_name = "allow-http"
      ip_version             = "IPV4"
    }
  ]

  egress_acl_entries = [
    {
      protocol               = "all"
      port                   = "-1/-1"
      destination_cidr_ip    = "0.0.0.0/0"
      policy                 = "accept"
      description            = "Allow all outbound"
      network_acl_entry_name = "allow-all-egress"
      ip_version             = "IPV4"
    }
  ]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vswitch_ids" {
  value = module.vpc.vswitch_ids
}

output "network_acl_id" {
  value = module.vpc.network_acl_id
}
