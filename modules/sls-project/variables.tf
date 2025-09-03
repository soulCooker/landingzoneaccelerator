# The name of the SLS project
variable "project_name" {
  description = "The name of the SLS project"
  type        = string
}

# The description of the SLS project
variable "description" {
  description = "The description of the SLS project"
  type        = string
  default     = ""
}

# The name of the logstore
variable "logstore_name" {
  description = "The name of the logstore"
  type        = string
}

# The data retention period in days
variable "retention_period" {
  description = "The data retention period in days"
  type        = number
  default     = 30
}

# The number of shards in the logstore
variable "shard_count" {
  description = "The number of shards in the logstore"
  type        = number
  default     = 2
}

# Whether to automatically split shards
variable "auto_split" {
  description = "Whether to automatically split shards"
  type        = bool
  default     = true
}

# The maximum number of shards for automatic splitting
variable "max_split_shard_count" {
  description = "The maximum number of shards for automatic splitting"
  type        = number
  default     = 64
}

# A mapping of tags to assign to the project
variable "tags" {
  description = "A mapping of tags to assign to the project"
  type        = map(string)
  default     = {}
}