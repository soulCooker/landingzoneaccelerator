## 概述

该Component用来搭建资源目录架构，包括：

- 开通资源目录
- 创建核心资源夹：Core
- 创建核心职能账号（按需配置，支持角色合并）：
    - 日志账号
    - 网络账号
    - 安全账号
    - 共享服务账号
    - 运维账号
    - 财务账号
    - 支持将多个角色合并到同一账号（如："log,security"）
- 委派管理员配置（所有支持委派管理员账户的服务，应开尽开）
  - 用户可以选择将某些服务委派到哪个职能账号上
  - 如果不选择，则按照默认配置进行委派（安全服务委派给安全账号，日志服务委派给日志账号等）
  - 支持在现有资源目录中创建账号并设置委派管理员

## 自定义资源夹

该组件不包含自定义资源夹功能。如果您需要创建额外的资源夹，请在您的根模块中直接使用 `alicloud_resource_manager_folder` 资源。

示例：
```hcl
# 在您的根模块中添加自定义资源夹
resource "alicloud_resource_manager_folder" "development" {
  folder_name      = "Development"
  parent_folder_id = module.resource_structure.core_folder_id
}

resource "alicloud_resource_manager_folder" "staging" {
  folder_name      = "Staging"  
  parent_folder_id = module.resource_structure.core_folder_id
}
```

## 用法

### 基本用法

```hcl
module "resource_structure" {
  source = "../components/resource-structure"

  # 资源目录自动检测创建
  # 核心资源夹名称
  core_folder_name = "Core"
  
  # 核心职能账号配置
  account_mapping = {
    log = {
      account_name_prefix = "MyOrg-Log"     # 登录账号前缀（必需）
    }
    network = {
      account_name_prefix  = "net"          # 登录账号前缀（必需）
      display_name = "Network-Core" # 控制台显示名称（可选，不填则使用account_name_prefix）
      billing_type = "Self-pay"     # 可选，默认Trusteeship
    }
    security = {
      account_name_prefix  = "sec"              # 登录账号前缀（必需）
      display_name = "Security-Center"  # 控制台显示名称（可选）
    }
  }

  # 委派服务配置 - 指定哪些服务委派给哪个角色
  delegated_services = {
    # 安全相关服务委派给安全账号
    "cloudfw.aliyuncs.com" = "security"     # 云防火墙
    "sas.aliyuncs.com"     = "security"     # 安全中心
    "waf.aliyuncs.com"     = "security"     # Web应用防火墙
    "ddosbgp.aliyuncs.com" = "security"     # DDoS高防
    
    # 日志相关服务委派给日志账号
    "actiontrail.aliyuncs.com" = "log"      # 操作审计
    "config.aliyuncs.com"      = "log"      # 配置审计
    "audit.log.aliyuncs.com"   = "log"      # 日志审计
    
    # 运维相关服务委派给运维账号
    "cloudmonitor.aliyuncs.com"   = "operations" # 云监控
    "prometheus.aliyuncs.com"     = "operations" # Prometheus监控
    "tag.aliyuncs.com"            = "operations" # 标签
    "ros.aliyuncs.com"            = "operations" # 资源编排
    "resourcecenter.aliyuncs.com" = "operations" # 资源中心
    "servicecatalog.aliyuncs.com" = "operations" # 服务目录
    "cloudsso.aliyuncs.com"       = "operations" # 云SSO
    "energy.aliyuncs.com"         = "operations" # 碳足迹
  }
}
```

### 角色分组用法

如果您希望将多个职能角色合并到同一个账号中，可以使用逗号分隔的角色名作为 key：

```hcl
module "resource_structure" {
  source = "../components/resource-structure"

  # 将日志和安全角色合并到同一个账号
  account_mapping = {
    "log,security" = {
      account_name_prefix  = "logsec"           # 登录账号前缀（必需）
      display_name = "LogSec-Combined"  # 控制台显示名称（可选）
    }
    network = {
      account_name_prefix = "network"           # 登录账号前缀（必需）
    }
  }

  # 委派时仍然使用单个角色名
  delegated_services = {
    "cloudfw.aliyuncs.com"     = "security"  # 自动解析到合并的账号
    "actiontrail.aliyuncs.com" = "log"       # 自动解析到合并的账号
    "cloudmonitor.aliyuncs.com" = "network"  # 委派给网络账号
  }
}
```

### 输入变量

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| core_folder_name | 核心资源夹名称 | string | "Core" |
| account_mapping | 职能账号映射配置。支持单角色或逗号分隔的角色列表作为key | map(object) | {} |
| delegated_services | 委派服务配置，指定哪些服务委派给哪个角色 | map(string) | 见variables.tf |

### account_mapping 对象属性

| 名称 | 描述 | 类型 | 必需 | 默认值 |
|------|------|------|------|--------|
| account_name_prefix | 账号登录名前缀（用于生成登录账号，格式严格） | string | 是 | - |
| display_name | 账号显示名称（在控制台中显示，不填则使用account_name_prefix） | string | 否 | null |
| billing_type | 结算类型：Trusteeship（托管）或Self-pay（自付） | string | 否 | "Trusteeship" |
| billing_account_id | 结算账号ID（当billing_type为Trusteeship时使用） | string | 否 | null |

### 输出变量

| 名称 | 描述 |
|------|------|
| resource_directory_id | 资源目录ID |
| core_folder_id | 核心资源夹ID |
| role_to_account_mapping | 职能角色到账号ID的映射 |
| accounts | 创建的账号信息 |
| delegated_services | 服务到委派管理员账号ID的映射 |

## 注意事项

1. **角色枚举限制**：所有角色必须是以下之一：`log`, `network`, `security`, `shared_services`, `operations`, `finance`

2. **委派服务验证**：在 `delegated_services` 中指定的所有角色必须有对应的已启用账号，否则会报错并阻止部署

3. **自定义资源夹**：本组件不提供自定义资源夹功能，如需要请在根模块中自行实现