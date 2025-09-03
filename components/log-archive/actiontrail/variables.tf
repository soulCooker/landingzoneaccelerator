variable "enable_oss_delivery" {
  description = "Whether to enable OSS delivery for ActionTrail"
  type        = bool
  default     = false
}

variable "enable_sls_delivery" {
  description = "Whether to enable SLS delivery for ActionTrail"
  type        = bool
  default     = false
}

variable "trail_name" {
  description = "The name of the ActionTrail trail"
  type        = string
  default     = "default-actiontrail"
}

variable "trail_status" {
  description = "The status of the trail. Valid values: Enable, Disable"
  type        = string
  default     = "Enable"
}

variable "event_type" {
  description = "The types of events to be recorded. Valid values: Write, Read, All"
  type        = string
  default     = "Write"
}

variable "trail_region" {
  description = "The regions to which the trail belongs. Valid values: cn-hangzhou, cn-shanghai, etc. Use 'All' for global trail"
  type        = string
  default     = "All"
}

variable "is_organization_trail" {
  description = "Specifies whether to create a multi-account trail"
  type        = bool
  default     = false
}

# OSS related variables
variable "oss_bucket_name" {
  description = "The name of the OSS bucket for storing ActionTrail logs"
  type        = string
  default     = null
}

variable "oss_log_retention_days" {
  description = "The number of days after which ActionTrail logs will expire in OSS"
  type        = number
  default     = 730
}

variable "oss_server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the OSS bucket"
  type        = bool
  default     = true
}

variable "oss_server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use for the OSS bucket. Valid value is AES256"
  type        = string
  default     = "AES256"
}

variable "oss_write_role_arn" {
  description = "The ARN of the RAM role used by ActionTrail to write to OSS"
  type        = string
  default     = null
}

variable "oss_force_destroy" {
  description = "Whether to force destroy the OSS bucket even if it contains objects"
  type        = bool
  default     = true
}

# SLS related variables
variable "sls_project_name" {
  description = "The name of the SLS project for storing ActionTrail logs"
  type        = string
  default     = null
}

variable "sls_project_description" {
  description = "The description of the SLS project"
  type        = string
  default     = "ActionTrail logs storage"
}

variable "sls_logstore_name" {
  description = "The name of the SLS logstore for storing ActionTrail logs"
  type        = string
  default     = "actiontrail-store"
}

variable "sls_retention_period" {
  description = "The retention period (in days) of SLS logs"
  type        = number
  default     = 180
}

variable "sls_write_role_arn" {
  description = "The ARN of the RAM role used by ActionTrail to write to SLS"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
