# OSS delivery configuration
variable "oss_enabled" {
  description = "Whether to enable OSS delivery"
  type        = bool
  default     = true
}

variable "oss_bucket_name" {
  description = "The name of the OSS bucket for config delivery"
  type        = string
  default     = null
}

variable "oss_bucket_force_destroy" {
  description = "When deleting a bucket, automatically delete all objects"
  type        = bool
  default     = false
}

variable "oss_bucket_versioning" {
  description = "The versioning status of the bucket"
  type        = bool
  default     = true
}

variable "oss_bucket_tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

variable "oss_bucket_storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "Standard"
}

variable "oss_bucket_acl" {
  description = "The canned ACL to apply to the bucket"
  type        = string
  default     = "private"
}

variable "oss_bucket_lifecycle_rule_enabled" {
  description = "Specifies whether the lifecycle rule is enabled"
  type        = bool
  default     = true
}

variable "oss_bucket_lifecycle_expiration_days" {
  description = "The number of days after which objects will expire. Default is 730 days (2 years)"
  type        = number
  default     = 730
}

variable "oss_bucket_server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the bucket"
  type        = bool
  default     = true
}

variable "oss_bucket_server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use. Valid value is AES256"
  type        = string
  default     = "AES256"
}

# SLS delivery configuration
variable "sls_enabled" {
  description = "Whether to enable SLS delivery"
  type        = bool
  default     = true
}

variable "sls_project_name" {
  description = "The name of the SLS project for config delivery"
  type        = string
  default     = null
}

variable "sls_project_description" {
  description = "The description of the SLS project"
  type        = string
  default     = "Config delivery project"
}

variable "sls_project_tags" {
  description = "A mapping of tags to assign to the project"
  type        = map(string)
  default     = {}
}

variable "sls_logstore_name" {
  description = "The name of the logstore"
  type        = string
  default     = "config-logstore"
}

variable "sls_logstore_retention_period" {
  description = "The data retention period in days"
  type        = number
  default     = 180
}

variable "sls_logstore_shard_count" {
  description = "The number of shards in the logstore"
  type        = number
  default     = 2
}

variable "sls_logstore_auto_split" {
  description = "Whether to automatically split shards"
  type        = bool
  default     = true
}

variable "sls_logstore_max_split_shard_count" {
  description = "The maximum number of shards for automatic splitting"
  type        = number
  default     = 64
}

# Config aggregator configuration
variable "use_existing_aggregator" {
  description = "Whether to use an existing config aggregator. If true, use existing_aggregator_id."
  type        = bool
  default     = false
}

variable "existing_aggregator_id" {
  description = "The ID of existing config aggregator to use when use_existing_aggregator is true."
  type        = string
  default     = null
}

variable "config_aggregator_name" {
  description = "The name of the config aggregator"
  type        = string
  default     = "enterprise"
}

variable "config_aggregator_description" {
  description = "The description of the config aggregator"
  type        = string
  default     = ""

  validation {
    condition     = var.config_aggregator_description == "" || (length(var.config_aggregator_description) >= 1 && length(var.config_aggregator_description) <= 256)
    error_message = "Aggregator description must be empty or between 1 and 256 characters."
  }
}
