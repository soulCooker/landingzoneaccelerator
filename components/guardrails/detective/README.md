## 概述

该Component用于创建和管理检测型防护规则（配置合规审计），包括：

- 支持创建新的配置聚合器或使用现有的聚合器
- 创建合规包
- 添加基于模板的规则（托管规则）
- 添加基于函数计算（FC）的自定义规则
- 选择性地将规则关联到合规包中

配置聚合器使用RD（资源目录）类型，会自动包含整个资源目录中的所有账号。
全局RD类型聚合器在一个阿里云账号中只能有一个，该模块提供两种模式：
1. **创建新模式**：创建新的RD类型聚合器
2. **使用现有模式**：直接使用用户指定的现有聚合器ID

## 用法

```hcl
module "detective_guardrails" {
  source = "../components/guardrails/detective"

  # 聚合器配置
  use_existing_aggregator = false  # true: 使用现有聚合器, false: 创建新聚合器
  aggregator_name         = "LandingZoneConfigAggregator"  # 仅在创建新聚合器时使用
  existing_aggregator_id  = null  # 仅在use_existing_aggregator=true时使用，指定现有聚合器ID

  # 是否启用合规包
  enable_compliance_pack = true

  # 合规包名称
  compliance_pack_name = "资源稳定性最佳实践"

  # 风险等级（1-4）
  risk_level = 1

  # 基于模板的规则列表（托管规则）
  template_based_rules = [
    {
      rule_name                       = "ECSInstanceNoPublicIP"
      description                     = "Ensure ECS instances do not have public IP addresses"
      source_template_id              = "ecs-instance-no-public-ip"
      input_parameters                = {}
      maximum_execution_frequency     = "One_Hour"
      scope_compliance_resource_types = ["ACS::ECS::Instance"]
      risk_level                      = 1
      trigger_types                   = "ConfigurationItemChangeNotification"
      tag_key_scope                   = ""
      tag_value_scope                 = ""
      region_ids_scope                = ""
      exclude_resource_ids_scope      = ""
      resource_group_ids_scope        = []
      add_to_compliance_pack          = true
    }
  ]

  # 基于函数计算的自定义规则列表
  custom_fc_rules = [
    {
      rule_name                       = "CustomECSInstanceCheck"
      description                     = "Custom check for ECS instances using Function Compute"
      source_arn                      = "acs:fc:cn-hangzhou:1234567890123456:services/custom-ecs-check-service.LATEST/functions/custom-ecs-check"
      input_parameters                = {}
      maximum_execution_frequency     = "One_Hour"
      scope_compliance_resource_types = ["ACS::ECS::Instance"]
      risk_level                      = 1
      trigger_types                   = "ConfigurationItemChangeNotification"
      tag_key_scope                   = ""
      tag_value_scope                 = ""
      region_ids_scope                = ""
      exclude_resource_ids_scope      = ""
      resource_group_ids_scope        = []
      add_to_compliance_pack          = true
    }
  ]
}
```

### 使用现有聚合器的示例

```hcl
module "detective_guardrails_existing" {
  source = "../components/guardrails/detective"

  # 使用现有聚合器
  use_existing_aggregator = true
  existing_aggregator_id  = "ca-xxxxxxxxxxxxxxxxx"  # 替换为实际的聚合器ID
  
  aggregator_description = "使用现有聚合器"

  # 其他配置...
  enable_compliance_pack = true
  compliance_pack_name   = "现有聚合器合规包"
  risk_level            = 1

  template_based_rules = [
    {
      rule_name          = "ExistingAggregatorRule"
      description        = "使用现有聚合器的规则"
      source_template_id = "ecs-instance-no-public-ip"
      risk_level         = 1
    }
  ]
}
```

### 输入变量

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| use_existing_aggregator | 是否使用现有的配置聚合器。如果为true，则使用existing_aggregator_id | bool | false |
| existing_aggregator_id | 当use_existing_aggregator为true时使用的现有聚合器ID | string | null |
| aggregator_name | 配置聚合器名称（仅在创建新聚合器时使用） | string | "LandingZoneConfigAggregator" |
| aggregator_description | 配置聚合器描述 | string | - |
| enable_compliance_pack | 是否启用合规包 | bool | true |
| compliance_pack_name | 合规包名称 | string | "LandingZoneCompliancePack" |
| risk_level | 风险等级（1-4） | number | 1 |
| template_based_rules | 基于模板的规则列表（托管规则） | list(object) | [] |
| custom_fc_rules | 基于函数计算的自定义规则列表 | list(object) | [] |

### template_based_rules 对象属性

| 名称 | 描述 | 类型 | 必需 | 默认值 |
|------|------|------|------|--------|
| rule_name | 规则名称 | string | 是 | - |
| description | 规则描述 | string | 否 | - |
| source_template_id | 模板ID（如："ecs-instance-no-public-ip"） | string | 是 | - |
| input_parameters | 输入参数 | map(string) | 否 | - |
| maximum_execution_frequency | 最大执行频率 | string | 否 | - |
| scope_compliance_resource_types | 资源类型范围 | list(string) | 否 | - |
| risk_level | 风险等级（1-4） | number | 是 | - |
| trigger_types | 触发类型 | string | 否 | - |
| tag_key_scope | 标签键范围 | string | 否 | - |
| tag_value_scope | 标签值范围 | string | 否 | - |
| region_ids_scope | 区域ID范围 | string | 否 | - |
| exclude_resource_ids_scope | 排除资源ID范围 | string | 否 | - |
| resource_group_ids_scope | 资源组ID范围 | list(string) | 否 | - |
| add_to_compliance_pack | 是否将规则添加到合规包中 | bool | 否 | true |

### custom_fc_rules 对象属性

| 名称 | 描述 | 类型 | 必需 | 默认值 |
|------|------|------|------|--------|
| rule_name | 规则名称 | string | 是 | - |
| description | 规则描述 | string | 否 | - |
| source_arn | 函数计算函数的ARN | string | 是 | - |
| input_parameters | 输入参数 | map(string) | 否 | - |
| maximum_execution_frequency | 最大执行频率 | string | 否 | - |
| scope_compliance_resource_types | 资源类型范围 | list(string) | 否 | - |
| risk_level | 风险等级（1-4） | number | 是 | - |
| trigger_types | 触发类型 | string | 否 | - |
| tag_key_scope | 标签键范围 | string | 否 | - |
| tag_value_scope | 标签值范围 | string | 否 | - |
| region_ids_scope | 区域ID范围 | string | 否 | - |
| exclude_resource_ids_scope | 排除资源ID范围 | string | 否 | - |
| resource_group_ids_scope | 资源组ID范围 | list(string) | 否 | - |
| add_to_compliance_pack | 是否将规则添加到合规包中 | bool | 否 | true |

### 输出变量

| 名称 | 描述 |
|------|------|
| aggregator_id | 配置账号组ID（现有的或新创建的） |
| compliance_pack_id | 合规包ID（如果启用） |
| rule_ids | 所有创建的配置规则ID列表 |
| template_rule_count | 创建的模板规则数量 |
| custom_fc_rule_count | 创建的自定义FC规则数量 |

## 注意事项

1. **RD类型聚合器唯一性**：一个阿里云账号只能有一个RD类型的配置聚合器
2. **聚合器模式选择**：
   - 创建新模式：适用于首次部署或需要新的聚合器
   - 使用现有模式：适用于已有聚合器的情况，直接使用现有ID
3. **账号范围**：RD类型聚合器自动包含整个资源目录中的所有账号，无需手动指定
4. **权限要求**：需要Config服务的相关权限才能创建和管理配置规则
5. **ID格式**：existing_aggregator_id 应为有效的聚合器ID格式（如：ca-xxxxxxxxxxxxxxxxx）
6. **默认行为**：默认创建新的聚合器，如需使用现有聚合器请设置 use_existing_aggregator = true