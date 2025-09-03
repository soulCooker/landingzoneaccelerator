provider "alicloud" {
  region = "cn-hangzhou"
}

module "resource_structure" {
  source = "../../../components/resource-structure"

  core_folder_name = "Core"

  account_mapping = {
    "log,security" = {
      account_name_prefix = "lz-logsec"
      display_name        = "LZ-LogSec"
    }
    network = {
      account_name_prefix = "net"
      display_name        = "Network-Core"
    }
    shared_services = {
      account_name_prefix = "shared"
      display_name        = "Shared-Services"
      billing_type        = "Self-pay"
    }
    operations = {
      account_name_prefix = "ops-monitor"
    }
  }

  delegated_services = {
    "cloudfw.aliyuncs.com"        = "security"
    "sas.aliyuncs.com"            = "security"
    "waf.aliyuncs.com"            = "security"
    "actiontrail.aliyuncs.com"    = "log"
    "config.aliyuncs.com"         = "log"
    "audit.log.aliyuncs.com"      = "log"
    "cloudmonitor.aliyuncs.com"   = "operations"
    "prometheus.aliyuncs.com"     = "operations"
    "ros.aliyuncs.com"            = "shared_services"
    "resourcecenter.aliyuncs.com" = "shared_services"
    "tag.aliyuncs.com"            = "shared_services"
    "cloudsso.aliyuncs.com"       = "shared_services"
  }
}

output "resource_directory_id" {
  value = module.resource_structure.resource_directory_id
}

output "core_folder_id" {
  value = module.resource_structure.core_folder_id
}

output "accounts" {
  value = module.resource_structure.accounts
}

output "role_to_account_mapping" {
  value = module.resource_structure.role_to_account_mapping
}

output "delegated_services" {
  value = module.resource_structure.delegated_services
}
