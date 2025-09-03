# Cloud Firewall variables

variable "create_cloud_firewall_instance" {
  description = "Whether to create a cloud firewall instance"
  type        = bool
  default     = true
}

variable "cloud_firewall_instance_name" {
  description = "The name of the cloud firewall instance"
  type        = string
  default     = "landingzone-central-firewall"
}

variable "cloud_firewall_instance_type" {
  description = "The type of the cloud firewall instance"
  type        = string
  default     = "premium"
}

variable "cloud_firewall_bandwidth" {
  description = "The bandwidth of the cloud firewall instance"
  type        = number
  default     = 100
}

variable "member_account_ids" {
  description = "List of member account IDs to be managed by the cloud firewall"
  type        = list(string)
  default     = []
}

variable "internet_acl_rules" {
  description = "List of internet ACL rules for the firewall"
  type = list(object({
    description     = string
    source_cidr     = string
    destination_cidr = string
    ip_protocol     = string
    source_port     = string
    destination_port = string
    policy          = string
    direction       = string
    priority        = number
  }))
  default = []
}

variable "nat_acl_rules" {
  description = "List of NAT ACL rules for the firewall"
  type = list(object({
    description     = string
    source_cidr     = string
    destination_cidr = string
    ip_protocol     = string
    source_port     = string
    destination_port = string
    policy          = string
    direction       = string
    priority        = number
  }))
  default = []
}

variable "vpc_acl_rules" {
  description = "List of VPC ACL rules for the firewall"
  type = list(object({
    description     = string
    source_cidr     = string
    destination_cidr = string
    ip_protocol     = string
    source_port     = string
    destination_port = string
    policy          = string
    direction       = string
    priority        = number
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "cloud_firewall_payment_type" {
  description = "The payment type of the cloud firewall instance"
  type        = string
  default     = "PayAsYouGo"
}

variable "control_policy_application_name" {
  description = "The application name for control policies"
  type        = string
  default     = "ANY"
}

variable "control_policy_source_type" {
  description = "The source type for control policies"
  type        = string
  default     = "net"
}

variable "control_policy_destination_type" {
  description = "The destination type for control policies"
  type        = string
  default     = "net"
}
