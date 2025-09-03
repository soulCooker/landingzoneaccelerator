# Variables for IaC Service Bootstrap
# Only user-configurable settings are defined here

variable "bucket_name" {
  description = "The name of the OSS bucket for code storage. If empty, a random name will be generated"
  type        = string
  default     = null
}
