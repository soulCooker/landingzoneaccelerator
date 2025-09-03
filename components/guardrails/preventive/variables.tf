variable "control_policies" {
  description = "A list of control policies to create and their attachments."
  type = list(object({
    name            = string
    description     = string
    policy_document = string
    target_ids      = list(string)
    attach_to_root  = bool
  }))
  default = []
  
  validation {
    condition = alltrue([
      for policy in var.control_policies :
      length(policy.name) >= 1 && length(policy.name) <= 128
    ])
    error_message = "Policy name must be between 1 and 128 characters."
  }
  
  validation {
    condition = alltrue([
      for policy in var.control_policies :
      (policy.attach_to_root == true && length(policy.target_ids) == 0) || 
      (policy.attach_to_root == false && length(policy.target_ids) > 0)
    ])
    error_message = "Either attach_to_root must be true (with no target_ids) or target_ids must be provided (with attach_to_root false)."
  }
  
  validation {
    condition = alltrue([
      for policy in var.control_policies :
      can(jsondecode(policy.policy_document))
    ])
    error_message = "Policy document must be valid JSON."
  }
}