# ---------------------------------------------------------------------------------------------------------------------
# Data Sources - Get current account information
# ---------------------------------------------------------------------------------------------------------------------
data "alicloud_account" "current" {}
# ---------------------------------------------------------------------------------------------------------------------
# Create VPC and VSwitch if needed
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_vpc" "kms_vpc" {
  count = var.create_kms_instance && var.create_vpc ? 1 : 0

  vpc_name   = var.vpc_name
  cidr_block = var.vpc_cidr_block
}

resource "alicloud_vswitch" "kms_vswitch" {
  count = var.create_kms_instance && var.create_vpc ? 1 : 0

  vpc_id     = alicloud_vpc.kms_vpc[0].id
  cidr_block = var.vswitch_cidr_block
  zone_id    = var.availability_zone
}

# ---------------------------------------------------------------------------------------------------------------------
# Service Activation - Enable KMS service
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_kms_instance" "main" {
  count = var.create_kms_instance ? 1 : 0

  instance_name = var.kms_instance_name
  zone_ids      = var.zone_ids != null ? var.zone_ids : (var.create_vpc ? [alicloud_vswitch.kms_vswitch[0].zone_id] : var.default_zone_ids)
  vswitch_ids   = var.vswitch_ids != null ? var.vswitch_ids : (var.create_vpc ? [alicloud_vswitch.kms_vswitch[0].id] : var.default_vswitch_ids)
  vpc_id        = var.vpc_id != null ? var.vpc_id : (var.create_vpc ? alicloud_vpc.kms_vpc[0].id : var.default_vpc_id)
  spec          = var.kms_instance_spec
  key_num       = var.kms_key_amount
  product_version = var.product_version
}