output "policy_ids" {
  description = "The IDs of the created control policies."
  value       = [for policy in alicloud_resource_manager_control_policy.default : policy.id]
}

output "attachment_ids" {
  description = "The IDs of all policy attachments."
  value       = [for attachment in alicloud_resource_manager_control_policy_attachment.default : attachment.id]
}