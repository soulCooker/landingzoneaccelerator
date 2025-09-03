output "cloud_firewall_instance_id" {
  description = "The ID of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].id, null)
}

output "cloud_firewall_instance_status" {
  description = "The status of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].status, null)
}

output "member_account_ids" {
  description = "The list of member account IDs managed by the cloud firewall"
  value       = var.member_account_ids
}

output "internet_acl_rule_count" {
  description = "The number of internet ACL rules created"
  value       = length(var.internet_acl_rules)
}

output "nat_acl_rule_count" {
  description = "The number of NAT ACL rules created"
  value       = length(var.nat_acl_rules)
}

output "vpc_acl_rule_count" {
  description = "The number of VPC ACL rules created"
  value       = length(var.vpc_acl_rules)
}