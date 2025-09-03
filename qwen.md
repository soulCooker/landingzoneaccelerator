# Terraform Alicloud Landing Zone Accelerator

## 项目概述

Terraform Alicloud Landing Zone Accelerator 是一个基于 Terraform 的阿里云 Landing Zone 解决方案加速器。它提供了一套标准化的基础设施即代码 (IaC) 模板，帮助企业快速构建和管理阿里云上的多账号环境，实现安全、合规和高效的云资源管理。

## 架构层次

项目采用三层架构设计，从下往上分别为：

1. **Module（模块）层**：
   - 最底层的细粒度模块
   - 通常满足以下条件才被抽象为一个 Module：
     - 负责单个产品的创建和配置
     - 使用到的 Terraform Resource 或 Datasource 数量 >= 2

2. **Component（组件）层**：
   - 更高维度的模块，可以认为是 Module 的组合
   - Landing Zone 的功能模块或子模块可以抽象为 Component
   - 抽象划分原则：
     - 存在调用身份上的依赖关系（如账号工厂需要先创建账号再配置基线）
     - 相互无关的子功能模块（如合规审计模块可分为防护规则和日志投递）

3. **Stack（栈）层**：
   - 按照 Landing Zone 模块划分
   - 串联 Component 形成 Landing Zone 的 8 大模块

## 主要组件

### 身份管理 (Identity)
- CloudSSO 配置
- 包括开通 CloudSSO、创建访问配置等功能
- 提供多种内置默认访问配置如 Administrator、Iam、Billing 等
- 支持创建自定义访问配置
- 可通过 Terraform 模块进行配置和管理

### 账号工厂 (Account Factory)
- 账号创建
- 账号基线配置

### 网络 (Network)
- VPC 等网络资源的创建和管理

### 安全 (Security)
- 安全相关的资源配置

### 合规审计 (Guardrails)
- 防护规则配置
- 日志投递配置

### 日志归档 (Log Archive)
- 操作审计日志投递
- 配置审计日志投递

### 资源结构 (Resource Structure)
- 资源组织结构的管理

## 使用方法

1. 根据需求选择相应的模块、组件或栈
2. 配置相应的变量参数
3. 使用 Terraform 命令进行部署

## 测试方法

项目中包含了各组件的测试配置，可以用于验证组件的功能。

### 测试 CloudSSO 组件

1. 进入测试目录：
   ```
   cd test/cloudsso-test
   ```

2. 配置阿里云认证信息：
   ```
   export ALICLOUD_ACCESS_KEY="your-access-key"
   export ALICLOUD_SECRET_KEY="your-secret-key"
   export ALICLOUD_REGION="cn-hangzhou"
   ```

3. 初始化 Terraform：
   ```
   terraform init
   ```

4. 查看执行计划：
   ```
   terraform plan
   ```

5. 应用配置（创建资源）：
   ```
   terraform apply
   ```

6. 清理资源（测试完成后）：
   ```
   terraform destroy
   ```

## 注意事项

- 该项目基于阿里云 Terraform Provider
- 需要具备阿里云账号和相应权限
- 建议在测试环境中先行验证再部署到生产环境
- 测试时会产生实际的云资源，请注意相关费用