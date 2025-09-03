# ---------------------------------------------------------------------------------------------------------------------
# Service Linked Role - Create service linked role for Cloud Firewall
# ---------------------------------------------------------------------------------------------------------------------
module "slr-with-role-name" {
  source     = "terraform-alicloud-modules/service-linked-role/alicloud"
  service_linked_role_with_role_names = [
    "AliyunServiceRoleForCloudFW"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Service Activation - Enable Cloud Firewall service
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_cloud_firewall_instance" "main" {
  count = var.create_cloud_firewall_instance ? 1 : 0

  payment_type = var.cloud_firewall_payment_type
  spec         = var.cloud_firewall_instance_type
  band_width   = var.cloud_firewall_bandwidth

  // 确保依赖于服务关联角色创建完成
  depends_on = [module.slr-with-role-name]
}

# ---------------------------------------------------------------------------------------------------------------------
# Service Activation - Enable Cloud Firewall service
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Member Account Management - Add member accounts to Cloud Firewall
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_cloud_firewall_instance_member" "members" {
  for_each = toset(var.member_account_ids)

  member_uid = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# Internet ACL Rules - Configure internet boundary firewall rules
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_cloud_firewall_control_policy" "internet" {
  depends_on = [alicloud_cloud_firewall_instance.main]

  for_each = {
    for i, rule in var.internet_acl_rules : i => rule
  }

  description      = each.value.description
  source           = each.value.source_cidr
  source_type      = var.control_policy_source_type
  destination      = each.value.destination_cidr
  destination_type = var.control_policy_destination_type
  proto            = each.value.ip_protocol
  dest_port        = each.value.destination_port
  acl_action       = each.value.policy
  direction        = each.value.direction
  application_name = var.control_policy_application_name
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT ACL Rules - Configure NAT boundary firewall rules
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_cloud_firewall_control_policy" "nat" {
  depends_on = [alicloud_cloud_firewall_instance.main]

  for_each = {
    for i, rule in var.nat_acl_rules : i => rule
  }

  description      = each.value.description
  source           = each.value.source_cidr
  source_type      = var.control_policy_source_type
  destination      = each.value.destination_cidr
  destination_type = var.control_policy_destination_type
  proto            = each.value.ip_protocol
  dest_port        = each.value.destination_port
  acl_action       = each.value.policy
  direction        = each.value.direction
  application_name = var.control_policy_application_name
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC ACL Rules - Configure VPC boundary firewall rules
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_cloud_firewall_control_policy" "vpc" {
  depends_on = [alicloud_cloud_firewall_instance.main]

  for_each = {
    for i, rule in var.vpc_acl_rules : i => rule
  }

  description      = each.value.description
  source           = each.value.source_cidr
  source_type      = var.control_policy_source_type
  destination      = each.value.destination_cidr
  destination_type = var.control_policy_destination_type
  proto            = each.value.ip_protocol
  dest_port        = each.value.destination_port
  acl_action       = each.value.policy
  direction        = each.value.direction
  application_name = var.control_policy_application_name
}