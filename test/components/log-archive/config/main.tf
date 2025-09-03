# ---------------------------------------------------------------------------------------------------------------------
# Provider Configuration
# ---------------------------------------------------------------------------------------------------------------------
provider "alicloud" {
  alias  = "log_archive"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "oss"
  region = "cn-hangzhou"
}

provider "alicloud" {
  alias  = "sls"
  region = "cn-beijing"
}

# ---------------------------------------------------------------------------------------------------------------------
# Random String Generator - Used for unique resource naming in tests
# ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Config Log Archive Module Test Configuration
# This test verifies:
# - Config aggregator creation
# - OSS delivery channel with bucket creation
# - SLS delivery channel with project and logstore creation
# - Resource tagging
# ---------------------------------------------------------------------------------------------------------------------
module "config_log_archive" {
  source = "../../../../components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  # OSS Delivery Configuration
  oss_enabled                                 = true
  oss_bucket_name                             = "test-config-bucket-${random_string.random.result}"
  oss_bucket_force_destroy                    = true
  oss_bucket_versioning                       = true
  oss_bucket_tags                             = { Environment = "test", Project = "landing-zone" }
  oss_bucket_storage_class                    = "Standard"
  oss_bucket_acl                              = "private"
  oss_bucket_lifecycle_rule_enabled           = true
  oss_bucket_lifecycle_expiration_days        = 730
  oss_bucket_server_side_encryption_enabled   = true
  oss_bucket_server_side_encryption_algorithm = "AES256"

  # SLS Delivery Configuration
  sls_enabled                        = true
  sls_project_name                   = "test-config-project-${random_string.random.result}"
  sls_project_description            = "Test Config logs storage"
  sls_project_tags                   = { Environment = "test", Project = "landing-zone" }
  sls_logstore_name                  = "config-logstore"
  sls_logstore_retention_period      = 180
  sls_logstore_shard_count           = 2
  sls_logstore_auto_split            = true
  sls_logstore_max_split_shard_count = 64

  # Config Aggregator Configuration
  use_existing_aggregator = true
  existing_aggregator_id  = "ca-c4320cb9794200a2f0de"
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs - Expose created resource identifiers for verification
# ---------------------------------------------------------------------------------------------------------------------
output "oss_bucket_name" {
  description = "The name of the OSS bucket used for Config logs"
  value       = module.config_log_archive.oss_bucket_name
}

output "oss_extranet_endpoint" {
  description = "The extranet access endpoint of the OSS bucket"
  value       = module.config_log_archive.oss_extranet_endpoint
}

output "oss_intranet_endpoint" {
  description = "The intranet access endpoint of the OSS bucket"
  value       = module.config_log_archive.oss_intranet_endpoint
}

output "sls_project_name" {
  description = "The name of the SLS project used for Config logs"
  value       = module.config_log_archive.sls_project_name
}

output "sls_project_description" {
  description = "The description of the SLS project"
  value       = module.config_log_archive.sls_project_description
}

output "sls_logstore_name" {
  description = "The name of the SLS logstore used for Config logs"
  value       = module.config_log_archive.sls_logstore_name
}

output "sls_retention_period" {
  description = "The retention period of the logstore"
  value       = module.config_log_archive.sls_retention_period
}

output "config_aggregator_id" {
  description = "The ID of the config aggregator"
  value       = module.config_log_archive.config_aggregator_id
}

output "config_aggregator_name" {
  description = "The name of the config aggregator"
  value       = module.config_log_archive.config_aggregator_name
}

output "config_delivery_channel_ids" {
  description = "The IDs of the config delivery channels"
  value       = module.config_log_archive.config_delivery_channel_ids
}
