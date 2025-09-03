provider "alicloud" {
  region = "cn-hangzhou"
}

module "preventive_guardrails" {
  source = "../../../../components/guardrails/preventive"

  control_policies = [
    {
      name = "DenyDeleteRolePolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["ram:DeleteRole", "ram:DeletePolicy"]
            Resource = "*"
          }
        ]
      })
      description    = "Deny deletion of RAM roles and policies"
      target_ids     = ["123456789012345678"] # Replace with actual account ID
      attach_to_root = false
    },
    {
      name = "RootLevelSecurityPolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["ecs:DeleteInstance"]
            Resource = "*"
          }
        ]
      })
      description    = "Security policy applied at root level"
      target_ids     = []
      attach_to_root = true
    }
  ]
}

output "policy_ids" {
  value = module.preventive_guardrails.policy_ids
}

output "attachment_ids" {
  value = module.preventive_guardrails.attachment_ids
}

data "alicloud_resource_manager_control_policies" "default" {
  depends_on = [module.preventive_guardrails]
  ids        = module.preventive_guardrails.policy_ids
}

output "policy_details" {
  value = data.alicloud_resource_manager_control_policies.default.policies
}
