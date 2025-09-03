provider "alicloud" {
  region = "cn-hangzhou"

}

module "eip" {
  source = "../../../modules/eip"

  # Basic EIP instances
  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "example-eip-1"
      tags = {
        env     = "test"
        purpose = "example"
      }
    },
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "example-eip-2"
      period           = null
      tags = {
        env     = "test"
        purpose = "example"
      }
    }
  ]

  # EIP association (optional - set to empty string to disable)
  eip_associate_instance_id = "ngw-xxxxxxxxxxxxxxxxx"

  # Common bandwidth package (optional)
  enable_common_bandwidth_package               = true
  common_bandwidth_package_name                 = "example-bandwidth-package"
  common_bandwidth_package_bandwidth            = "10"
  common_bandwidth_package_internet_charge_type = "PayByBandwidth"
}

output "eip_instances" {
  description = "List of created EIP instances"
  value       = module.eip.eip_instances
}

output "common_bandwidth_package_id" {
  description = "ID of the common bandwidth package"
  value       = module.eip.common_bandwidth_package_id
}

output "eip_count" {
  description = "Number of EIP instances created"
  value       = length(module.eip.eip_instances)
}

output "first_eip_address" {
  description = "IP address of the first EIP instance"
  value       = length(module.eip.eip_instances) > 0 ? module.eip.eip_instances[0].ip_address : null
}
