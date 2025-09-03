# Get current account ID and region
data "alicloud_account" "this" {}
data "alicloud_regions" "this" {
  current = true
}

# Create SLS project
resource "alicloud_log_project" "project" {
  project_name = var.project_name
  description  = var.description
  tags         = var.tags
}

# Create SLS logstore
resource "alicloud_log_store" "store" {
  project_name          = alicloud_log_project.project.project_name
  logstore_name         = var.logstore_name
  retention_period      = var.retention_period
  shard_count           = var.shard_count
  auto_split            = var.auto_split
  max_split_shard_count = var.max_split_shard_count

  depends_on = [alicloud_log_project.project]
}

# Create index for the logstore to enable searching
resource "alicloud_log_store_index" "index" {
  project  = alicloud_log_project.project.project_name
  logstore = alicloud_log_store.store.logstore_name

  full_text {
    case_sensitive = false
    token          = ", ' \" ; = ( ) [ ] { } ? @ & < > / : \n \t \r"
  }

  field_search {
    name             = "eventName"
    type             = "text"
    case_sensitive   = false
    token            = ", ' \" ; = ( ) [ ] { } ? @ & < > / : \n \t \r"
    enable_analytics = true
  }

  field_search {
    name             = "eventSource"
    type             = "text"
    case_sensitive   = false
    token            = ", ' \" ; = ( ) [ ] { } ? @ & < > / : \n \t \r"
    enable_analytics = true
  }

  depends_on = [alicloud_log_store.store]
}
