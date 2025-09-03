data "alicloud_account" "current" {}

# Create Resource Directory (Terraform will handle existing RD gracefully)
resource "alicloud_resource_manager_resource_directory" "default" {}

# Get Resource Directory information
data "alicloud_resource_manager_resource_directories" "default" {
  depends_on = [alicloud_resource_manager_resource_directory.default]
}

resource "alicloud_resource_manager_folder" "core" {
  folder_name      = var.core_folder_name
  parent_folder_id = data.alicloud_resource_manager_resource_directories.default.directories[0].root_folder_id
}

locals {
  parsed_account_mapping = {
    for key, account in var.account_mapping :
    key => {
      roles    = can(regex(",", key)) ? split(",", key) : [key]
      account  = account
      group_id = can(regex(",", key)) ? join("+", sort(split(",", key))) : key
    }
  }

  role_to_group_id = merge([
    for key, parsed in local.parsed_account_mapping : {
      for role in parsed.roles : role => parsed.group_id
    }
  ]...)

  unique_account_group_ids = distinct([
    for parsed in local.parsed_account_mapping : parsed.group_id
  ])

  group_id_to_roles = {
    for gid in local.unique_account_group_ids :
    gid => [
      for key, parsed in local.parsed_account_mapping :
      parsed.roles if parsed.group_id == gid
    ][0]
  }

  account_configs = {
    for gid in local.unique_account_group_ids :
    gid => {
      roles               = local.group_id_to_roles[gid]
      primary_role        = local.group_id_to_roles[gid][0]
      account_name_prefix = [for key, parsed in local.parsed_account_mapping : parsed.account.account_name_prefix if parsed.group_id == gid][0]
      display_name        = [for key, parsed in local.parsed_account_mapping : parsed.account.display_name if parsed.group_id == gid][0]
      billing_type        = [for key, parsed in local.parsed_account_mapping : parsed.account.billing_type if parsed.group_id == gid][0]
      billing_account_id  = [for key, parsed in local.parsed_account_mapping : parsed.account.billing_account_id if parsed.group_id == gid][0]
    }
  }

  available_roles_for_delegation = flatten([
    for gid, config in local.account_configs : [
      for role in config.roles : role
    ]
  ])

  specified_admin_roles = values(var.delegated_services)
  invalid_admin_roles = [
    for role in local.specified_admin_roles :
    role if !contains(local.available_roles_for_delegation, role)
  ]

  service_delegated_admins = {
    for service, role in var.delegated_services :
    service => alicloud_resource_manager_account.functional[local.role_to_group_id[role]].id
  }
}

resource "alicloud_resource_manager_account" "functional" {
  for_each = local.account_configs

  display_name        = each.value.display_name != null ? each.value.display_name : each.value.account_name_prefix
  account_name_prefix = each.value.account_name_prefix
  folder_id           = alicloud_resource_manager_folder.core.id
  payer_account_id = each.value.billing_type == "Trusteeship" ? (
    each.value.billing_account_id != null ? each.value.billing_account_id : data.alicloud_account.current.id
  ) : null
}

resource "null_resource" "validate_delegated_admin_roles" {
  count = length(local.invalid_admin_roles) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: The following roles specified in delegated_services do not have corresponding enabled accounts: ${join(", ", local.invalid_admin_roles)}. Please enable these accounts or remove them from delegated_services.' >&2 && exit 1"
  }
}

resource "alicloud_resource_manager_delegated_administrator" "service_specific" {
  for_each = length(local.invalid_admin_roles) == 0 ? local.service_delegated_admins : {}

  service_principal = each.key
  account_id        = each.value

  depends_on = [
    alicloud_resource_manager_resource_directory.default,
    alicloud_resource_manager_folder.core,
    alicloud_resource_manager_account.functional,
    null_resource.validate_delegated_admin_roles,
  ]
}
