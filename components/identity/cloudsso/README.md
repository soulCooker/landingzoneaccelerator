## 概述

该Component用于CloudSSO相关配置，包括：

- 开通CloudSSO
- 创建CloudSSO访问配置
    - 内置默认的通用访问配置（默认全部开启，按需关闭），包括：
        - Administrator：具有账号内全局权限，即管理所有阿里云资源的权限。
        - Iam：具有访问控制管理员权限，负责企业员工在阿里云的身份权限管理。
        - Billing：具有查询和管理账单，账户资金管理，发票合同管理等全部财务管理权限。
        - AuditAdministrator：具有配置审计、操作审计和日志管理的全部权限，同时有权查看所有资源现状。
        - LogAdministrator：具有日志管理的权限。
        - LogAudit：具有日志的查看权限。
        - NetworkAdministrator：具有网络相关服务的所有权限，并有安全组的权限。
        - SecurityAudit：具有安全产品的查询安全数据的权限，但不可管理安全产品的配置。
        - SecurityAdministrator：具有所有安全产品的管理权限。
    - 创建自定义访问配置

## 用法

```hcl
module "cloudsso" {
  source = "../components/identity/cloudsso"

  directory_name = "MyCloudSSO"

  # Enable default access configurations
  enable_default_access_configurations = true

  # Custom access configurations
  access_configurations = [
    {
      name                        = "CustomAdmin"
      description                 = "Custom admin access configuration"
      session_duration            = 7200
      managed_system_policies = ["AliyunECSFullAccess"]
      inline_custom_policy = {
        policy_name     = "CustomInlinePolicy"
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
```

### 输入变量

| Name | Description | Type | Default |
|------|-------------|------|---------|
| directory_name | The name of the CloudSSO directory | string | null |
| access_configurations | List of custom access configurations to create | list(object) | [] |
| enable_default_access_configurations | Whether to enable default access configurations | bool | true |
| default_access_configurations | Default access configurations to create if enabled | map(object) | See variables.tf |

### access_configurations 对象字段

| 字段名 | 描述 | 类型 | 必需 | 默认值 |
|--------|------|------|------|--------|
| name | 访问配置名称 | string | 是 | - |
| description | 访问配置描述 | string | 否 | - |
| relay_state | 中继状态URL | string | 否 | "https://home.console.aliyun.com/" |
| session_duration | 会话持续时间（秒） | number | 否 | 3600 |
| managed_system_policies | 系统托管策略名称列表 | list(string) | 否 | [] |
| inline_custom_policy | 内联自定义策略对象 | object | 否 | null |

### inline_custom_policy 对象字段

| 字段名 | 描述 | 类型 | 必需 |
|--------|------|------|------|
| policy_name | 策略名称 | string | 是 |
| policy_document | 策略文档（JSON格式） | string | 是 |

### 输出变量

| Name | Description | 
|------|-------------|
| directory_id | The ID of the CloudSSO directory |
| directory_name | The name of the CloudSSO directory |
| default_access_configuration_ids | The IDs of the default access configurations |
| custom_access_configuration_ids | The IDs of the custom access configurations |
