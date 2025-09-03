## 概述

该Component用于创建和管理预防型防护规则（Control Policy事前审计），包括：

- 创建多个管控策略
- 将管控策略下发到目标账号或目录
- 支持将策略附加到根目录或特定目标（两者互斥）

## 用法

```hcl
module "preventive_guardrails" {
  source = "../components/guardrails/preventive"

  # 管控策略列表
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
      target_ids     = ["123456789012345678"]  # Replace with actual account IDs
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
```

### 输入变量

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| control_policies | 管控策略列表 | list(object) | [] |

### control_policies 对象属性

| 名称 | 描述 | 类型 | 必需 | 默认值 |
|------|------|------|------|--------|
| name | 管控策略的名称 | string | 是 | - |
| policy_document | 管控策略的文档，JSON格式 | string | 是 | - |
| description | 管控策略的描述 | string | 否 | "" |
| target_ids | 要附加策略的目标ID列表 | list(string) | 否 | [] |
| attach_to_root | 是否将策略附加到资源目录的根节点 | bool | 否 | false |

注意：`target_ids`和`attach_to_root`是互斥的。当`attach_to_root`为true时，`target_ids`必须为空。

### 输出变量

| 名称 | 描述 |
|------|------|
| policy_ids | 管控策略的ID列表 |
| attachment_ids | 所有策略附加的ID列表（包括根节点和特定目标） |