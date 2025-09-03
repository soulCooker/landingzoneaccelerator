output "resource_directory_id" {
  description = "The ID of the resource directory."
  value       = data.alicloud_resource_manager_resource_directories.default.directories[0].id
}

output "root_folder_id" {
  description = "The ID of the root folder."
  value       = data.alicloud_resource_manager_resource_directories.default.directories[0].root_folder_id
}

output "core_folder_id" {
  description = "The ID of the core folder."
  value       = alicloud_resource_manager_folder.core.id
}

output "accounts" {
  description = "Information about created functional accounts."
  value = {
    for gid, account in alicloud_resource_manager_account.functional :
    gid => {
      id           = account.id
      display_name = account.display_name
      roles        = local.account_configs[gid].roles
    }
  }
}

output "role_to_account_mapping" {
  description = "Mapping of individual roles to their account IDs."
  value = {
    for role, group_id in local.role_to_group_id :
    role => alicloud_resource_manager_account.functional[group_id].id
  }
}

output "delegated_services" {
  description = "Mapping of services to their delegated administrator account IDs."
  value       = local.service_delegated_admins
}
