## 概述

该Module用来快速创建RAM角色，并绑定所需的权限策略，包括：

- 创建自定义权限策略（可选）
- 创建RAM角色，并绑定权限策略：系统策略和自定义策略

## 用法

您可以通过以下步骤在您的Terraform模板中使用它。

```·hcl
module "log_archive" {
  // 请替换为正确的相对路径
  source = "./modules/ram-role"

  role_name = "tf-landing-zone-accelerator-role"
  trusted_principal_arns = [
    "acs:ram::<your-account-uid>:root"
  ]
  managed_system_policy_names = [
    "AliyunECSFullAccess"
  ]
  inline_custom_policies = [
    {
      "policy_name" : "tf-landing-zone-accelerator-policy",
      "policy_document" : "{\"Version\":\"1\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.253.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | 1.253.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ram_role"></a> [ram\_role](#module\_ram\_role) | https://mirrors.aliyun.com/terraform/modules/registry.terraform.io/terraform-alicloud-modules/ram-role/alicloud/2.0.0.zip | n/a |

## Resources

| Name | Type |
|------|------|
| [alicloud_ram_policy.landing_zone](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/ram_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_admin_policy"></a> [attach\_admin\_policy](#input\_attach\_admin\_policy) | Whether to attach an admin policy to a role | `bool` | `false` | no |
| <a name="input_attach_readonly_policy"></a> [attach\_readonly\_policy](#input\_attach\_readonly\_policy) | Whether to attach a readonly policy to a role | `bool` | `false` | no |
| <a name="input_inline_custom_policies"></a> [inline\_custom\_policies](#input\_inline\_custom\_policies) | List of custom policies to be created and attached to the RAM role within this module. This is different from managed_custom_policy_names, which refers to existing custom policy names. | <pre>list(object({<br/>    policy_name     = string<br/>    policy_document = string<br/>    description     = optional(string)<br/>    force           = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_force"></a> [force](#input\_force) | Whether to delete ram policy forcibly, default to true | `bool` | `true` | no |
| <a name="input_managed_system_policy_names"></a> [managed\_system\_policy\_names](#input\_managed\_system\_policy\_names) | List of names of managed policies of System type to attach to RAM role | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds, refer to the parameter MaxSessionDuration of [CreateRole](https://api.aliyun.com/document/Ram/2015-05-01/CreateRole) | `number` | `3600` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of the RAM role. | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of role. If not set, a default name with prefix 'terraform-ram-role-' will be returned | `string` | `null` | no |
| <a name="input_role_requires_mfa"></a> [role\_requires\_mfa](#input\_role\_requires\_mfa) | Whether role requires MFA | `bool` | `true` | no |
| <a name="input_trust_policy"></a> [trust\_policy](#input\_trust\_policy) | A custom role trust policy. Conflicts with 'trusted\_principal\_arns' and 'trusted\_services' | `string` | `null` | no |
| <a name="input_trusted_principal_arns"></a> [trusted\_principal\_arns](#input\_trusted\_principal\_arns) | ARNs of Alibaba Cloud entities who can assume these roles. Conflicts with 'trust\_policy' | `list(string)` | `[]` | no |
| <a name="input_trusted_services"></a> [trusted\_services](#input\_trusted\_services) | Alibaba Cloud Services that can assume these roles. Conflicts with 'trust\_policy' | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of RAM role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of RAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the ram role |
<!-- END_TF_DOCS -->