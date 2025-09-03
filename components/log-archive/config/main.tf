# Get current account ID and region
data "alicloud_account" "this" {
  provider = alicloud.log_archive
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

# Enable config service
module "enable_config_service" {
  source = "../../../modules/config-configuration-recorder"

  providers = {
    alicloud = alicloud.log_archive
  }
}

# Create OSS bucket for config delivery if enabled
module "oss_bucket" {
  source = "../../../modules/oss-bucket"

  count = var.oss_enabled ? 1 : 0

  providers = {
    alicloud = alicloud.oss
  }

  # Pass all OSS configuration variables to the module
  bucket_name                      = var.oss_bucket_name
  acl                              = var.oss_bucket_acl
  force_destroy                    = var.oss_bucket_force_destroy
  storage_class                    = var.oss_bucket_storage_class
  versioning                       = var.oss_bucket_versioning
  tags                             = var.oss_bucket_tags
  lifecycle_rule_enabled           = var.oss_bucket_lifecycle_rule_enabled
  lifecycle_expiration_days        = var.oss_bucket_lifecycle_expiration_days
  server_side_encryption_enabled   = var.oss_bucket_server_side_encryption_enabled
  server_side_encryption_algorithm = var.oss_bucket_server_side_encryption_algorithm

  depends_on = [data.alicloud_oss_service.open]
}

# Create SLS project for config delivery if enabled
module "sls_project" {
  source = "../../../modules/sls-project"

  count = var.sls_enabled ? 1 : 0

  providers = {
    alicloud = alicloud.sls
  }

  # SLS project configuration
  project_name          = var.sls_project_name != null ? var.sls_project_name : "config-delivery-${data.alicloud_account.this.id}"
  description           = var.sls_project_description
  tags                  = var.sls_project_tags
  logstore_name         = var.sls_logstore_name != null ? var.sls_logstore_name : "config-logstore-${data.alicloud_account.this.id}"
  retention_period      = var.sls_logstore_retention_period
  shard_count           = var.sls_logstore_shard_count
  auto_split            = var.sls_logstore_auto_split
  max_split_shard_count = var.sls_logstore_max_split_shard_count

  depends_on = [data.alicloud_log_service.open]
}

# Create config aggregator for resource directory
resource "alicloud_config_aggregator" "aggregator" {
  count = var.use_existing_aggregator ? 0 : 1

  provider = alicloud.log_archive
  # Aggregator name and description
  aggregator_name = var.config_aggregator_name
  # RD type aggregator automatically includes all accounts in the resource directory
  aggregator_type = "RD"
  description     = var.config_aggregator_description

  depends_on = [module.enable_config_service]
}

locals {
  aggregator_id = var.use_existing_aggregator ? var.existing_aggregator_id : alicloud_config_aggregator.aggregator[0].id
}

# Create OSS aggregate delivery channel if enabled
resource "alicloud_config_aggregate_delivery" "oss" {
  provider = alicloud.log_archive
  # Only create if OSS delivery is enabled
  count = var.oss_enabled ? 1 : 0

  # Link to the aggregator
  aggregator_id = local.aggregator_id
  # Delivery channel configuration
  delivery_channel_name                  = "config-oss-delivery"
  delivery_channel_type                  = "OSS"
  delivery_channel_target_arn            = module.oss_bucket[0].bucket_arn
  configuration_item_change_notification = true
  configuration_snapshot                 = true

  depends_on = [module.oss_bucket, alicloud_config_aggregator.aggregator]
}

# Create SLS aggregate delivery channel if enabled
resource "alicloud_config_aggregate_delivery" "sls" {
  provider = alicloud.log_archive
  # Only create if SLS delivery is enabled
  count = var.sls_enabled ? 1 : 0

  # Link to the aggregator
  aggregator_id = local.aggregator_id
  # Delivery channel configuration
  delivery_channel_name                  = "config-sls-delivery"
  delivery_channel_type                  = "SLS"
  delivery_channel_target_arn            = module.sls_project[0].logstore_arn
  configuration_item_change_notification = true
  configuration_snapshot                 = true

  depends_on = [module.sls_project, alicloud_config_aggregator.aggregator]
}
