# KMS variables

variable "create_kms_instance" {
  description = "Whether to create a KMS instance"
  type        = bool
  default     = true
}

variable "kms_instance_name" {
  description = "The name of the KMS instance"
  type        = string
  default     = "landingzone-central-kms"
}

variable "kms_instance_spec" {
  description = "The specification of the KMS instance"
  type        = string
  default     = "1000"
}

variable "kms_key_amount" {
  description = "The number of keys that can be protected in the KMS instance"
  type        = number
  default     = 1000
}

variable "product_version" {
  description = "The product version of the KMS instance"
  type        = string
  default     = "3"
}

variable "zone_ids" {
  description = "List of zone IDs to deploy the KMS instance"
  type        = list(string)
  default     = null
}

variable "vswitch_ids" {
  description = "List of VSwitch IDs to deploy the KMS instance"
  type        = list(string)
  default     = null
}

variable "vpc_id" {
  description = "VPC ID to deploy the KMS instance"
  type        = string
  default     = null
}

variable "create_vpc" {
  description = "Whether to create a VPC for the KMS instance"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "kms-vpc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vswitch_cidr_block" {
  description = "The CIDR block for the VSwitch"
  type        = string
  default     = "10.0.0.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the VSwitch"
  type        = string
  default     = "cn-hangzhou-g"
}

variable "default_zone_ids" {
  description = "Default zone IDs to use if not creating VPC and zone_ids not provided"
  type        = list(string)
  default     = ["cn-hangzhou-g"]
}

variable "default_vswitch_ids" {
  description = "Default VSwitch IDs to use if not creating VPC and vswitch_ids not provided"
  type        = list(string)
  default     = []
}

variable "default_vpc_id" {
  description = "Default VPC ID to use if not creating VPC and vpc_id not provided"
  type        = string
  default     = ""
}