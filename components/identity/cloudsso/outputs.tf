output "directory_id" {
  description = "The ID of the CloudSSO directory."
  value       = alicloud_cloud_sso_directory.default.id
}

output "directory_name" {
  description = "The name of the CloudSSO directory."
  value       = alicloud_cloud_sso_directory.default.directory_name
}

output "default_access_configuration_ids" {
  description = "The IDs of the default access configurations."
  value = var.enable_default_access_configurations ? {
    for i, name in keys(var.default_access_configurations) : 
    name => alicloud_cloud_sso_access_configuration.default[i].access_configuration_id
  } : {}
}

output "custom_access_configuration_ids" {
  description = "The IDs of the custom access configurations."
  value = {
    for i, config in var.access_configurations : 
    config.name => alicloud_cloud_sso_access_configuration.custom[i].access_configuration_id
  }
}