# Data source to get master account information
data "alicloud_account" "master" {
  provider = alicloud.master
}

# Data source to get iam account information
data "alicloud_account" "iam" {
  provider = alicloud.iam
}

# Enable CloudSSO service
data "alicloud_cloud_sso_service" "enable" {
  provider = alicloud.master
  enable   = "On"
}

# Create SSO directory (CloudSSO instance)
resource "alicloud_cloud_sso_directory" "default" {
  provider       = alicloud.master
  directory_name = var.directory_name != null ? var.directory_name : "CloudSSO-${data.alicloud_account.master.id}"
}

# Delegate account if iam account is not the same as master account
# TODO: 

# Create default access configurations if enabled
resource "alicloud_cloud_sso_access_configuration" "default" {
  provider                  = alicloud.iam
  count                     = var.enable_default_access_configurations ? length(keys(var.default_access_configurations)) : 0
  directory_id              = alicloud_cloud_sso_directory.default.id
  access_configuration_name = keys(var.default_access_configurations)[count.index]
  description               = values(var.default_access_configurations)[count.index].description
  relay_state               = "https://home.console.aliyun.com/"
  session_duration          = 3600

  dynamic "permission_policies" {
    for_each = concat(
      # System managed policies
      values(var.default_access_configurations)[count.index].managed_system_policies != null ? [
        for policy in values(var.default_access_configurations)[count.index].managed_system_policies : {
          type     = "System"
          name     = policy
          document = null
        }
      ] : [],
      # Inline custom policies
      values(var.default_access_configurations)[count.index].inline_custom_policy != null ? [
        {
          type     = "Inline"
          name     = values(var.default_access_configurations)[count.index].inline_custom_policy.policy_name
          document = values(var.default_access_configurations)[count.index].inline_custom_policy.policy_document
        }
      ] : []
    )
    content {
      permission_policy_type     = permission_policies.value.type
      permission_policy_name     = permission_policies.value.name
      permission_policy_document = permission_policies.value.document
    }
  }

  timeouts {
    delete = "2m"
  }
}

# Create custom access configurations
resource "alicloud_cloud_sso_access_configuration" "custom" {
  provider                  = alicloud.iam
  count                     = length(var.access_configurations)
  directory_id              = alicloud_cloud_sso_directory.default.id
  access_configuration_name = var.access_configurations[count.index].name
  description               = var.access_configurations[count.index].description != null ? var.access_configurations[count.index].description : "Custom access configuration"
  relay_state               = var.access_configurations[count.index].relay_state != null ? var.access_configurations[count.index].relay_state : "https://home.console.aliyun.com/"
  session_duration          = var.access_configurations[count.index].session_duration != null ? var.access_configurations[count.index].session_duration : 3600

  dynamic "permission_policies" {
    for_each = concat(
      # System managed policies
      var.access_configurations[count.index].managed_system_policies != null ? [
        for policy in var.access_configurations[count.index].managed_system_policies : {
          type     = "System"
          name     = policy
          document = null
        }
      ] : [],
      # Inline custom policies
      var.access_configurations[count.index].inline_custom_policy != null ? [
        {
          type     = "Inline"
          name     = var.access_configurations[count.index].inline_custom_policy.policy_name
          document = var.access_configurations[count.index].inline_custom_policy.policy_document
        }
      ] : []
    )
    content {
      permission_policy_type     = permission_policies.value.type
      permission_policy_name     = permission_policies.value.name
      permission_policy_document = permission_policies.value.document
    }
  }

  timeouts {
    delete = "2m"
  }
}
