# ---------------------------------------------------------------------------------------------------------------------
# Data Sources - Get current account information
# ---------------------------------------------------------------------------------------------------------------------
data "alicloud_account" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# Service Activation - Enable Security Center service
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_threat_detection_instance" "main" {
  count = var.enable_security_center ? 1 : 0

  payment_type = var.security_center_payment_type
  version_code = var.security_center_instance_type
  buy_number   = var.security_center_buy_number
}

# ---------------------------------------------------------------------------------------------------------------------
# Service Linked Role - Create Security Center service-linked role
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_security_center_service_linked_role" "main" {
  count = var.enable_security_center ? 1 : 0

  product_name = "SecurityCenter"
}

# ---------------------------------------------------------------------------------------------------------------------
# Member Account Management - Add member accounts to Security Center
# ---------------------------------------------------------------------------------------------------------------------
# Member account management is not currently supported in this version
# resource "alicloud_cloud_firewall_instance_member" "members" {
#   for_each = var.enable_security_center ? toset(var.member_account_ids) : toset([])

#   member_uid = each.value
#   status     = "on"
# }