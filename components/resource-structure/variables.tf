variable "core_folder_name" {
  description = "The name of the core folder."
  type        = string
  default     = "Core"

  validation {
    condition     = length(var.core_folder_name) > 0 && length(var.core_folder_name) <= 32
    error_message = "Core folder name must be between 1 and 32 characters."
  }
}

variable "account_mapping" {
  description = "Mapping of functional roles to accounts. Key can be a single role or comma-separated roles like 'log,security' for grouping multiple roles. Only specify accounts you want to create - no need for enabled flags."
  type = map(object({
    account_name_prefix = string
    display_name        = optional(string)
    billing_type        = optional(string, "Trusteeship")
    billing_account_id  = optional(string)
  }))
  default = {
    log = {
      account_name_prefix = "log"
      billing_type        = "Trusteeship"
    }
    network = {
      account_name_prefix = "network"
      billing_type        = "Trusteeship"
    }
    security = {
      account_name_prefix = "security"
      billing_type        = "Trusteeship"
    }
    shared_services = {
      account_name_prefix = "shared"
      billing_type        = "Trusteeship"
    }
    operations = {
      account_name_prefix = "ops"
      billing_type        = "Trusteeship"
    }
    finance = {
      account_name_prefix = "finance"
      billing_type        = "Trusteeship"
    }
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      length(account.account_name_prefix) > 0 && length(account.account_name_prefix) <= 32
    ])
    error_message = "Each account's account_name_prefix is required and must be between 1 and 32 characters."
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      account.display_name == null || (try(length(account.display_name), 0) > 0 && try(length(account.display_name), 0) <= 50)
    ])
    error_message = "Each account's display_name, if provided, must be between 1 and 50 characters."
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      can(regex("^(Trusteeship|Self-pay)$", account.billing_type))
    ])
    error_message = "Billing type must be either 'Trusteeship' or 'Self-pay'."
  }


}

variable "delegated_services" {
  description = "Map of services to delegate as administrators to specific account roles. Key is service identifier, value is the role to delegate to."
  type        = map(string)
  default = {
    # Security services
    "cloudfw.aliyuncs.com"     = "security"
    "sas.aliyuncs.com"         = "security"
    "waf.aliyuncs.com"         = "security"
    "ddosbgp.aliyuncs.com"     = "security"
    "bastionhost.aliyuncs.com" = "security"
    "sddp.aliyuncs.com"        = "security"

    # Log and audit services
    "actiontrail.aliyuncs.com" = "log"
    "config.aliyuncs.com"      = "log"
    "audit.log.aliyuncs.com"   = "log"

    # Operations and monitoring services
    "cloudmonitor.aliyuncs.com"   = "operations"
    "prometheus.aliyuncs.com"     = "operations"
    "tag.aliyuncs.com"            = "operations"
    "ros.aliyuncs.com"            = "operations"
    "resourcecenter.aliyuncs.com" = "operations"
    "servicecatalog.aliyuncs.com" = "operations"
    "energy.aliyuncs.com"         = "operations"

    # Identity and access management services
    "cloudsso.aliyuncs.com" = "shared_services"
  }

  validation {
    condition = alltrue([
      for service in keys(var.delegated_services) :
      can(regex("\\.aliyuncs\\.com$", service))
    ])
    error_message = "All service identifiers must be valid trusted service identifiers ending with '.aliyuncs.com'."
  }
}
