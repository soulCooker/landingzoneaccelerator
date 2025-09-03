data "alicloud_account" "this" {}

data "alicloud_regions" "this" {
  current = true
}

# Create OSS bucket
resource "alicloud_oss_bucket" "bucket" {
  bucket = var.bucket_name

  force_destroy = var.force_destroy
  storage_class = var.storage_class
  tags          = var.tags

  # Enable or suspend versioning based on var.versioning
  versioning {
    status = var.versioning ? "Enabled" : "Suspended"
  }

  dynamic "server_side_encryption_rule" {
    for_each = var.server_side_encryption_enabled ? [1] : []
    content {
      sse_algorithm = var.server_side_encryption_algorithm
    }
  }

  # Configure object lifecycle rules for automatic expiration
  lifecycle_rule {
    enabled = var.lifecycle_rule_enabled
    prefix  = ""

    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}

# Set bucket ACL
resource "alicloud_oss_bucket_acl" "bucket_acl" {
  bucket = alicloud_oss_bucket.bucket.id
  acl    = var.acl
}
