output "kms_instance_id" {
  description = "The ID of the KMS instance"
  value       = try(alicloud_kms_instance.main[0].id, null)
}

output "kms_instance_status" {
  description = "The status of the KMS instance"
  value       = try(alicloud_kms_instance.main[0].status, null)
}

output "kms_instance_name" {
  description = "The name of the KMS instance"
  value       = try(alicloud_kms_instance.main[0].instance_name, null)
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(alicloud_vpc.kms_vpc[0].id, null)
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = try(alicloud_vswitch.kms_vswitch[0].id, null)
}