provider "alicloud" {
  region = "cn-hangzhou"
}

module "nat_gateway" {
  source = "../../../modules/nat-gateway"

  # VPC and VSwitch configuration (using placeholder IDs for testing)
  vpc_id     = "vpc-xxxxxxxxxxxxxxxxxxxxx" # Replace with actual VPC ID
  vswitch_id = "vsw-xxxxxxxxxxxxxxxxxxxxx" # Replace with actual VSwitch ID

  # NAT Gateway configuration
  nat_gateway_name = "example-nat-gateway"
  network_type     = "internet"
  payment_type     = "PayAsYouGo"
  period           = null

  # Tags
  tags = {
    env     = "test"
    purpose = "example"
    module  = "nat-gateway"
  }

  # EIP association (using placeholder EIP IDs)
  association_eip_ids = [
    "eip-xxxxxxxxxxxxxxxxxxxxx", # Replace with actual EIP ID
    "eip-xxxxxxxxxxxxxxxxxxxxx"  # Replace with actual EIP ID
  ]

  # SNAT entries configuration
  snat_entries = [
    {
      source_cidr             = "192.168.0.0/24"
      source_vswitch_id       = null
      snat_ips                = ["x.x.x.x", "y.y.y.y"] # Replace with actual IP
      use_all_associated_eips = false
      snat_entry_name         = "example-snat-entry-1"
      eip_affinity            = 0
    },
    {
      source_cidr             = null
      source_vswitch_id       = "vsw-xxxxxxxxxxxxxxxxxxxxx" # Replace with actual VSwitch ID
      snat_ips                = []
      use_all_associated_eips = true
      snat_entry_name         = "example-snat-entry-2"
      eip_affinity            = 1
    }
  ]
}

output "nat_gateway_id" {
  description = "ID of the created NAT Gateway"
  value       = module.nat_gateway.nat_gateway_id
}

output "nat_gateway_snat_entry_ids" {
  description = "IDs of the created SNAT entries"
  value       = module.nat_gateway.nat_gateway_snat_entry_ids
}
