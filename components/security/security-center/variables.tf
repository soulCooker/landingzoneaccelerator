# Security Center variables

variable "enable_security_center" {
  description = "Whether to enable Security Center"
  type        = bool
  default     = true
}

variable "security_center_instance_type" {
  description = "The type of the Security Center instance"
  type        = string
  default     = "premium"
}

variable "member_account_ids" {
  description = "List of member account IDs to be managed by Security Center"
  type        = list(string)
  default     = []
}

variable "security_center_log_storage_days" {
  description = "The number of days to store security logs"
  type        = number
  default     = 180
}

variable "security_center_threat_analysis_enabled" {
  description = "Whether to enable threat analysis"
  type        = bool
  default     = true
}

variable "security_center_vulnerability_scan_enabled" {
  description = "Whether to enable vulnerability scanning"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}