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
# ActionTrail Module Test Configuration
# This test verifies:
# - Trail creation with both OSS and SLS delivery enabled
# - Organization-wide trail configuration
# - Custom resource naming with random strings
# - Resource tagging
# ---------------------------------------------------------------------------------------------------------------------
module "actiontrail" {
  source = "../../../../components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  # Basic ActionTrail Configuration
  trail_name            = "test-actiontrail-${random_string.random.result}"
  trail_status          = "Enable"
  event_type            = "All" # Record all types of events
  trail_region          = "All" # Enable global trail
  is_organization_trail = true  # Enable organization-wide tracking

  # OSS Delivery Configuration
  enable_oss_delivery                  = true
  oss_bucket_name                      = "test-actiontrail-bucket-${random_string.random.result}"
  oss_force_destroy                    = true
  oss_log_retention_days               = 365 # 1 year retention for testing
  oss_server_side_encryption_enabled   = false
  oss_server_side_encryption_algorithm = "AES256"

  # SLS Delivery Configuration
  enable_sls_delivery     = true
  sls_project_name        = "test-actiontrail-${random_string.random.result}"
  sls_project_description = "Test ActionTrail logs storage"
  sls_logstore_name       = "actiontrail-store"
  sls_retention_period    = 180

  # Resource Tags
  tags = {
    Environment = "test"
    Project     = "landing-zone"
    CreatedBy   = "terraform"
    TestCase    = "actiontrail"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs - Expose created resource identifiers for verification
# ---------------------------------------------------------------------------------------------------------------------
output "trail_name" {
  description = "The name of the created ActionTrail trail"
  value       = module.actiontrail.trail_name
}

output "oss_bucket_name" {
  description = "The name of the OSS bucket used for ActionTrail logs"
  value       = module.actiontrail.oss_bucket_name
}

output "sls_project_name" {
  description = "The name of the SLS project used for ActionTrail logs"
  value       = module.actiontrail.sls_project_name
}

output "sls_logstore_name" {
  description = "The name of the SLS logstore used for ActionTrail logs"
  value       = module.actiontrail.sls_logstore_name
}
