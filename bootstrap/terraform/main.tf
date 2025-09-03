# Terraform configuration for IaC Service initialization
# This replaces the functionality from init_ram_role.py and init_oss.py

terraform {
  required_version = ">= 1.0"
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# Configure the Alicloud Provider
provider "alicloud" {
  region = "cn-beijing"
}

# Generate random suffix for bucket name if not provided
resource "random_integer" "default" {
  max = 99999
  min = 10000
}

locals {

  # Resource naming
  bucket_name       = var.bucket_name != null ? var.bucket_name : "iac-service-stack-code-${random_integer.default.result}"
  topic_name        = "${local.bucket_name}-event-topic"
  subscription_name = "${local.bucket_name}-event-subscription"
  event_rule_name   = "${local.bucket_name}-event-rule"

  # RAM configuration
  role_name = "IaCServiceStackRoleTest"

  # MNS configuration
  notification_endpoint = "acs:mns:cn-beijing:1511928242963727:/queues/stack-callback"
  notification_role_arn = "acs:ram::1511928242963727:role/stackmnsrolewithservice"

  # OSS bucket ARN for event rule
  oss_bucket_arn = "acs:oss:cn-beijing:1511928242963727:${local.bucket_name}"

  # MNS settings
  mns_message_retention_period = 345600 # 4 days
}

# RAM Role for IaC Service
resource "alicloud_ram_role" "iac_service_role" {
  role_name   = local.role_name
  description = "RAM role for IaC service operations"

  assume_role_policy_document = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["iac.aliyuncs.com"]
      }
    }]
    Version = "1"
  })

  force = true
}

# Attach AdministratorAccess system policy to role
resource "alicloud_ram_role_policy_attachment" "admin_access_attachment" {
  policy_name = "AdministratorAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.iac_service_role.role_name
}

# OSS Bucket for code storage
resource "alicloud_oss_bucket" "code_storage" {
  bucket = local.bucket_name

  lifecycle_rule {
    id      = "code_lifecycle"
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  lifecycle {
    ignore_changes = [
      versioning,
    ]
  }
}

resource "alicloud_oss_bucket_acl" "default" {
  bucket = alicloud_oss_bucket.code_storage.bucket
  acl    = "private"
}

resource "alicloud_oss_bucket_versioning" "default" {
  status = "Enabled"
  bucket = alicloud_oss_bucket.code_storage.bucket
}


# MNS Topic for OSS event notifications
resource "alicloud_message_service_topic" "oss_event_topic" {
  topic_name       = local.topic_name
  max_message_size = 65536
}


# MNS Topic Subscription
resource "alicloud_message_service_subscription" "oss_event_subscription" {
  topic_name        = alicloud_message_service_topic.oss_event_topic.topic_name
  subscription_name = local.subscription_name
  push_type         = "queue"
  endpoint          = local.notification_endpoint
}

# OSS Event Notification Rule
resource "alicloud_message_service_event_rule" "oss_event_rule" {
  event_types = [
    "ObjectCreated:All",
    "ObjectModified:All"
  ]

  match_rules = [
    [
      {
        suffix      = ".json"
        match_state = "true"
        prefix      = "${local.oss_bucket_arn}/repo"
        name        = ""
      }
    ]
  ]

  endpoint {
    endpoint_value = alicloud_message_service_topic.oss_event_topic.topic_name
    endpoint_type  = "topic"
  }

  rule_name = local.event_rule_name
}

