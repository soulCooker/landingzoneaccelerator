# ---------------------------------------------------------------------------------------------------------------------
# Data Sources - Get current account and region information
# ---------------------------------------------------------------------------------------------------------------------
data "alicloud_account" "current" {
  provider = alicloud.log_archive
}

# ---------------------------------------------------------------------------------------------------------------------
# Local Variables - Generate default resource names if not provided
# ---------------------------------------------------------------------------------------------------------------------
locals {
  oss_bucket_name  = try(var.oss_bucket_name, "actiontrail-${data.alicloud_account.current.id}")
  sls_project_name = try(var.sls_project_name, "actiontrail-${data.alicloud_account.current.id}")
}


# ---------------------------------------------------------------------------------------------------------------------
# Service Activation - Enable required services for ActionTrail delivery
# ---------------------------------------------------------------------------------------------------------------------
# Enable Log Service - Check if Log Service is enabled
data "alicloud_log_service" "open" {
  provider = alicloud.sls
  enable   = "On"
}

# Enable OSS Service - Check if OSS Service is enabled
data "alicloud_oss_service" "open" {
  provider = alicloud.oss
  enable   = "On"
}

# ---------------------------------------------------------------------------------------------------------------------
# OSS Module - Create OSS bucket for ActionTrail logs if enabled
# ---------------------------------------------------------------------------------------------------------------------
module "oss_bucket" {
  count  = var.enable_oss_delivery ? 1 : 0
  source = "../../../modules/oss-bucket"

  providers = {
    alicloud = alicloud.oss
  }

  bucket_name                      = local.oss_bucket_name
  force_destroy                    = var.oss_force_destroy
  lifecycle_rule_enabled           = true
  lifecycle_expiration_days        = var.oss_log_retention_days
  tags                             = try(var.tags, {})
  server_side_encryption_enabled   = var.oss_server_side_encryption_enabled
  server_side_encryption_algorithm = var.oss_server_side_encryption_algorithm

  depends_on = [data.alicloud_oss_service.open]
}

# ---------------------------------------------------------------------------------------------------------------------
# SLS Module - Create SLS project and logstore for ActionTrail logs if enabled
# ---------------------------------------------------------------------------------------------------------------------
module "sls_project" {
  count  = var.enable_sls_delivery ? 1 : 0
  source = "../../../modules/sls-project"

  providers = {
    alicloud = alicloud.sls
  }

  project_name     = local.sls_project_name
  description      = var.sls_project_description
  logstore_name    = var.sls_logstore_name
  retention_period = var.sls_retention_period
  tags             = try(var.tags, {})

  depends_on = [data.alicloud_log_service.open]
}

# ---------------------------------------------------------------------------------------------------------------------
# ActionTrail - Create trail with OSS and SLS delivery configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "alicloud_actiontrail_trail" "main" {
  provider = alicloud.log_archive
  # Basic configuration
  trail_name            = var.trail_name
  status                = var.trail_status
  event_rw              = var.event_type
  trail_region          = var.trail_region
  is_organization_trail = var.is_organization_trail

  # OSS delivery configuration - Uses default service role if not specified
  oss_write_role_arn = var.enable_oss_delivery ? (
    var.oss_write_role_arn != null ? var.oss_write_role_arn : "acs:ram::${data.alicloud_account.current.id}:role/aliyunserviceroleforactiontrail"
  ) : null
  oss_bucket_name = var.enable_oss_delivery ? module.oss_bucket[0].bucket : null

  # SLS delivery configuration - Uses default service role if not specified
  sls_write_role_arn = var.enable_sls_delivery ? (
    var.sls_write_role_arn != null ? var.sls_write_role_arn : "acs:ram::${data.alicloud_account.current.id}:role/aliyunserviceroleforactiontrail"
  ) : null
  sls_project_arn = var.enable_sls_delivery ? module.sls_project[0].project_arn : null
}
