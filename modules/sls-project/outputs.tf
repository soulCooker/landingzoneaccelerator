output "project_name" {
  description = "The name of the SLS project"
  value       = alicloud_log_project.project.project_name
}

output "project_description" {
  description = "The description of the SLS project"
  value       = alicloud_log_project.project.description
}

output "logstore_name" {
  description = "The name of the logstore"
  value       = alicloud_log_store.store.logstore_name
}

output "retention_period" {
  description = "The retention period of the logstore"
  value       = alicloud_log_store.store.retention_period
}

output "project_arn" {
  description = "The ARN of the SLS project"
  value       = format("acs:log:%s:%s:project/%s", data.alicloud_regions.this.regions[0].id, data.alicloud_account.this.id, alicloud_log_project.project.project_name)
}

output "logstore_arn" {
  description = "The ARN of the SLS logstore"
  value       = format("acs:log:%s:%s:project/%s/logstore/%s", data.alicloud_regions.this.regions[0].id, data.alicloud_account.this.id, alicloud_log_project.project.project_name, alicloud_log_store.store.logstore_name)
}
