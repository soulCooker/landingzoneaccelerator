## 概述

该Component用于设置配置审计的日志投递，包括：

- 开通OSS，并创建OSS Bucket（如果需要投递到OSS）
- 开通SLS，并创建SLS Project（如果需要投递到SLS）
- 创建配置审计全局账号组
- 创建配置审计全局投递，允许投递到
  - OSS
  - SLS（其中，SLS Logstore的日志存储时间，默认为180天）

## 用法

```hcl
module "config_log_archive" {
  source = "../components/log-archive/config"

  region = "cn-hangzhou"

  # OSS相关配置
  oss_enabled                           = true
  oss_bucket_name                      = "my-config-bucket"
  oss_bucket_force_destroy             = false
  oss_bucket_versioning                = true
  oss_bucket_tags                      = { Environment = "prod" }
  oss_bucket_storage_class             = "Standard"
  oss_bucket_acl                       = "private"
  oss_bucket_lifecycle_rule_enabled    = true
  oss_bucket_lifecycle_expiration_days = 730
  oss_bucket_server_side_encryption_enabled = true

  # SLS相关配置
  sls_enabled                                 = true
  sls_project_name                            = "my-config-project"
  sls_project_description                     = "Config delivery project"
  sls_project_tags                            = { Environment = "prod" }
  sls_logstore_name                           = "config-logstore"
  sls_logstore_retention_period               = 180
  sls_logstore_shard_count                    = 2
  sls_logstore_auto_split                     = true
  sls_logstore_max_split_shard_count          = 64

  # Config聚合器配置
  config_aggregator_name        = "landingzone-all"
  config_aggregator_description = "Landing Zone Config Aggregator for all accounts"
}
```

### 输入变量

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| region | 资源创建的区域 | string | - |
| oss_enabled | 是否启用OSS投递 | bool | true |
| oss_bucket_name | OSS bucket名称 | string | null (自动生成) |
| oss_bucket_force_destroy | 删除bucket时是否自动删除所有对象 | bool | false |
| oss_bucket_versioning | bucket的版本控制状态 | bool | true |
| oss_bucket_tags | 分配给bucket的标签映射 | map(string) | {} |
| oss_bucket_storage_class | bucket的存储类别 | string | "Standard" |
| oss_bucket_acl | 应用于bucket的访问控制列表 | string | "private" |
| oss_bucket_lifecycle_rule_enabled | 是否启用生命周期规则 | bool | true |
| oss_bucket_lifecycle_expiration_days | 对象过期天数 | number | 730 |
| oss_bucket_server_side_encryption_enabled | 是否启用服务端加密 | bool | true |
| oss_bucket_server_side_encryption_algorithm | 服务端加密算法 | string | "AES256" |
| sls_enabled | 是否启用SLS投递 | bool | true |
| sls_project_name | SLS项目名称 | string | null (自动生成) |
| sls_project_description | SLS项目描述 | string | "Config delivery project" |
| sls_project_tags | 分配给项目的标签映射 | map(string) | {} |
| sls_logstore_name | logstore名称 | string | "config-logstore" |
| sls_logstore_retention_period | 数据保留天数 | number | 180 |
| sls_logstore_shard_count | logstore中的分片数 | number | 2 |
| sls_logstore_auto_split | 是否自动分割分片 | bool | true |
| sls_logstore_max_split_shard_count | 自动分割的最大分片数 | number | 64 |
| config_aggregator_name | 配置聚合器名称 | string | "landingzone-all" |
| config_aggregator_description | 配置聚合器描述 | string | "Landing Zone Config Aggregator for all accounts" |

### 输出变量

| 名称 | 描述 |
|------|------|
| oss_bucket_name | OSS bucket名称 |
| oss_extranet_endpoint | OSS bucket的外网访问端点 |
| oss_intranet_endpoint | OSS bucket的内网访问端点 |
| sls_project_name | SLS项目名称 |
| sls_project_description | SLS项目描述 |
| sls_logstore_name | logstore名称 |
| sls_retention_period | logstore保留期 |
| config_aggregator_id | 配置聚合器ID |
| config_aggregator_name | 配置聚合器名称 |
| config_delivery_channel_ids | 配置投递通道ID列表 |