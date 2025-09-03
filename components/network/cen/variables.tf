variable "cen_instance_name" {
  description = "The name of the CEN instance."
  type        = string
  default     = null

  validation {
    condition = var.cen_instance_name == null || length(var.cen_instance_name) == 0 || (
      length(var.cen_instance_name) >= 1 &&
      length(var.cen_instance_name) <= 128 &&
      !startswith(var.cen_instance_name, "http://") &&
      !startswith(var.cen_instance_name, "https://")
    )
    error_message = "cen_instance_name can be null or empty, or if not empty must be 1-128 characters and must not start with 'http://' or 'https://'."
  }
}

variable "cen_instance_description" {
  description = "The description for the CEN instance."
  type        = string
  default     = null

  validation {
    condition = var.cen_instance_description == null || length(var.cen_instance_description) == 0 || (
      length(var.cen_instance_description) >= 1 &&
      length(var.cen_instance_description) <= 256 &&
      !startswith(var.cen_instance_description, "http://") &&
      !startswith(var.cen_instance_description, "https://")
    )
    error_message = "cen_instance_description can be null or empty, or if not empty must be 1-256 characters and must not start with 'http://' or 'https://'."
  }
}

variable "transit_router_name" {
  description = "The name of the Transit Router to create."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_name == null || length(var.transit_router_name) == 0 || (
      length(var.transit_router_name) >= 1 &&
      length(var.transit_router_name) <= 128 &&
      !startswith(var.transit_router_name, "http://") &&
      !startswith(var.transit_router_name, "https://")
    )
    error_message = "transit_router_name can be null or empty, or if not empty must be 1-128 characters and must not start with 'http://' or 'https://'."
  }
}

variable "transit_router_description" {
  description = "The description of the Transit Router."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_description == null || length(var.transit_router_description) == 0 || (
      length(var.transit_router_description) >= 1 &&
      length(var.transit_router_description) <= 256 &&
      !startswith(var.transit_router_description, "http://") &&
      !startswith(var.transit_router_description, "https://")
    )
    error_message = "transit_router_description can be null or empty, or if not empty must be 1-256 characters and must not start with 'http://' or 'https://'."
  }
}

variable "cen_instance_tags" {
  description = "A map of tags to assign to the CEN instance."
  type        = map(string)
  default     = null
}

variable "transit_router_tags" {
  description = "A map of tags to assign to the Transit Router."
  type        = map(string)
  default     = null
}
