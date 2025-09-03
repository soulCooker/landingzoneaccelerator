variable "directory_name" {
  description = "The name of the CloudSSO directory. If null, it will be generated based on the account ID. Format: only lowercase letters, numbers, or hyphens (-). Cannot start or end with a hyphen, cannot contain two consecutive hyphens, and cannot start with 'd-'. Length: 2~64 characters."
  type        = string
  default     = null
  validation {
    condition = (
      var.directory_name == null ||
      (
        length(var.directory_name) >= 2 &&
        length(var.directory_name) <= 64 &&
        can(regex("^[a-z0-9]([a-z0-9\\-]*[a-z0-9])?$", var.directory_name)) &&
        !can(regex("--", var.directory_name)) &&
        !can(regex("^d-", var.directory_name))
      )
    )
    error_message = "directory_name must be 2~64 characters, only contain lowercase letters, numbers, or hyphens (-), cannot start or end with a hyphen, cannot contain two consecutive hyphens, and cannot start with 'd-'."
  }
}

variable "access_configurations" {
  description = "List of access configurations to create."
  type = list(object({
    name                    = string
    description             = optional(string)
    relay_state             = optional(string, "https://home.console.aliyun.com/")
    session_duration        = optional(number, 3600)
    managed_system_policies = optional(list(string), [])
    inline_custom_policy = optional(object({
      policy_name     = string
      policy_document = string
    }), null)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      length(config.name) > 0 && length(config.name) <= 32 && can(regex("^[a-zA-Z0-9-]+$", config.name))
    ])
    error_message = "Each access configuration name must be between 1 and 32 characters and can only contain letters, digits, and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      config.description == null || (try(length(config.description), 0) > 0 && try(length(config.description), 0) <= 1024)
    ])
    error_message = "Each access configuration description, if provided, must be between 1 and 1024 characters."
  }

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      config.session_duration == null || (try(config.session_duration, 0) >= 900 && try(config.session_duration, 0) <= 43200)
    ])
    error_message = "Each access configuration session_duration, if provided, must be between 900 and 43200 seconds."
  }
}

variable "enable_default_access_configurations" {
  description = "Whether to enable default access configurations."
  type        = bool
  default     = true
}

variable "default_access_configurations" {
  description = "Default access configurations to create if enabled."
  type = map(object({
    description             = optional(string)
    managed_system_policies = optional(list(string), [])
    inline_custom_policy = optional(object({
      policy_name     = string
      policy_document = string
    }), null)
  }))
  default = {
    Administrator = {
      description             = "Provides full access to Alibaba Cloud services and resources."
      managed_system_policies = ["AdministratorAccess"]
    }
    Iam = {
      description             = "Provides full access to identity and access management."
      managed_system_policies = ["AliyunRAMFullAccess", "AliyunCloudSSOFullAccess"]
      inline_custom_policy = {
        policy_name     = "Iam-InlinePolicy"
        policy_document = <<-EOT
        {
          "Version": "1",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "resourcemanager:GetResourceDirectory",
                "governance:GetResourceStructureBlueprint",
                "governance:*SamlProvider",
                "governance:GetIamRole",
                "governance:ListIamRoles",
                "governance:*RoleBasedSsoBlueprint",
                "governance:*CloudSsoBlueprint"
              ],
              "Resource": "*"
            }
          ]
        }
        EOT
      }
    }
    Billing = {
      description             = "Grants permissions for billing and cost management. This includes viewing account usage and viewing and modifying budgets and payment methods."
      managed_system_policies = ["AliyunFinanceConsoleFullAccess", "AliyunBSSFullAccess"]
    }
    AuditAdministrator = {
      description             = "Provides full access to audit management."
      managed_system_policies = ["AliyunConfigFullAccess", "AliyunActionTrailFullAccess", "AliyunLogFullAccess"]
      inline_custom_policy = {
        policy_name     = "AuditAdmin-InlinePolicy"
        policy_document = <<-EOT
        {
          "Version": "1",
          "Statement": [
            {
              "Action": [
                "*:Describe*",
                "*:List*",
                "*:Get*",
                "*:BatchGet*",
                "*:Query*",
                "*:BatchQuery*",
                "actiontrail:LookupEvents",
                "dm:Desc*",
                "dm:SenderStatistics*"
              ],
              "Resource": "*",
              "Effect": "Allow"
            },
            {
              "Action": [
                "bss:*",
                "efc:*"
              ],
              "Effect": "Deny",
              "Resource": "*"
            }
          ]
        }
        EOT
      }
    }
    LogAdministrator = {
      description             = "Provides full access to log management."
      managed_system_policies = ["AliyunLogFullAccess"]
    }
    LogAudit = {
      description             = "Provides readonly access to log management."
      managed_system_policies = ["AliyunLogReadOnlyAccess"]
    }
    NetworkAdministrator = {
      description = "Grants full access permissions to Alibaba Cloud services and actions required to set up and configure Alibaba Cloud network resources."
      managed_system_policies = [
        "AliyunVPCFullAccess",
        "AliyunNATGatewayFullAccess",
        "AliyunEIPFullAccess",
        "AliyunCENFullAccess",
        "AliyunVPNGatewayFullAccess",
        "AliyunSLBFullAccess",
        "AliyunExpressConnectFullAccess",
        "AliyunCommonBandwidthPackageFullAccess",
        "AliyunSmartAccessGatewayFullAccess",
        "AliyunGlobalAccelerationFullAccess",
        "AliyunECSNetworkInterfaceManagementAccess",
        "AliyunDNSFullAccess",
        "AliyunCDNFullAccess",
        "AliyunYundunNewBGPAntiDDoSServicePROFullAccess"
      ]
      inline_custom_policy = {
        policy_name     = "NetworkAdmin-InlinePolicy"
        policy_document = <<-EOT
        {
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "ecs:*SecurityGroup*",
              "Resource": "*"
            }
          ],
          "Version": "1"
        }
        EOT
      }
    }
    SecurityAudit = {
      description = "Grants access to read security configuration metadata."
      managed_system_policies = [
        "AliyunYundunHighReadOnlyAccess",
        "AliyunYundunAegisReadOnlyAccess",
        "AliyunYundunSASReadOnlyAccess",
        "AliyunYundunBastionHostReadOnlyAccess",
        "AliyunYundunCertReadOnlyAccess",
        "AliyunYundunDDosReadOnlyAccess",
        "AliyunYundunWAFReadOnlyAccess",
        "AliyunYundunDbAuditReadOnlyAccess",
        "AliyunYundunCloudFirewallReadOnlyAccess",
        "AliyunYundunIdaasReadOnlyAccess"
      ]
    }
    SecurityAdministrator = {
      description             = "Grants full access to security configuration."
      managed_system_policies = ["AliyunYundunFullAccess"]
    }
  }
}
