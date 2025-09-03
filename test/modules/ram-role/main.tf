provider "alicloud" {
  region = "cn-hangzhou"

}

module "ram_role" {
  source = "../../../modules/ram-role"

  role_name = "tf-landing-zone-accelerator-test"

  trusted_principal_arns = [
    "acs:ram::1234567890123456:root"
  ]

  managed_system_policy_names = [
    "AliyunECSFullAccess"
  ]

  inline_custom_policies = [
    {
      policy_name     = "tf-landing-zone-accelerator-test-01"
      policy_document = "{\"Version\":\"1\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
    },
    {
      policy_name     = "tf-landing-zone-accelerator-test-02"
      policy_document = "{\"Version\":\"1\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"

    }
  ]

}


output "role_name" {
  value = module.ram_role.role_name
}

output "role_arn" {
  value = module.ram_role.role_arn
}

output "role_id" {
  value = module.ram_role.role_id
}
