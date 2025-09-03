provider "alicloud" {
  alias  = "master"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "iam"
  region = "cn-shanghai"
}

module "cloudsso" {
  source = "../../../components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "landingzone-accelerator-20250818"

  # Enable default access configurations
  enable_default_access_configurations = true

  # Custom access configurations
  access_configurations = [
    {
      name                    = "CustomAdmin"
      description             = "Custom admin access configuration"
      session_duration        = 7200
      managed_system_policies = ["AliyunECSFullAccess"]
      inline_custom_policy = {
        policy_name = "CustomInlinePolicy"
        policy_document = jsonencode({
          Version = "1"
          Statement = [
            {
              Effect   = "Allow"
              Action   = ["oss:GetObject"]
              Resource = "*"
            }
          ]
        })
      }
    }
  ]
}

output "directory_id" {
  value = module.cloudsso.directory_id
}

output "directory_name" {
  value = module.cloudsso.directory_name
}

output "default_access_configuration_ids" {
  value = module.cloudsso.default_access_configuration_ids
}

output "custom_access_configuration_ids" {
  value = module.cloudsso.custom_access_configuration_ids
}
