# The name of the OSS bucket
variable "bucket_name" {
  description = "The name of the OSS bucket"
  type        = string
}

# When deleting a bucket, automatically delete all objects
variable "force_destroy" {
  description = "When deleting a bucket, automatically delete all objects"
  type        = bool
  default     = false
}

# The versioning status of the bucket
variable "versioning" {
  description = "The versioning status of the bucket"
  type        = bool
  default     = false
}

# A mapping of tags to assign to the bucket
variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

# The storage class of the bucket
variable "storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "Standard"
}

# The canned ACL to apply to the bucket
variable "acl" {
  description = "The canned ACL to apply to the bucket"
  type        = string
  default     = "private"
}

# Specifies whether the lifecycle rule is enabled
variable "lifecycle_rule_enabled" {
  description = "Specifies whether the lifecycle rule is enabled"
  type        = bool
  default     = true
}

# The number of days after which objects will expire. Default is 730 days (2 years)
variable "lifecycle_expiration_days" {
  description = "The number of days after which objects will expire. Default is 730 days (2 years)"
  type        = number
  default     = 730
}

# Specifies whether to enable server-side encryption for the bucket
variable "server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the bucket"
  type        = bool
  default     = true
}

# The server-side encryption algorithm to use. Valid value is AES256
variable "server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use. Valid value is AES256"
  type        = string
  default     = "AES256"
}
