==Deprecated==

> 统一放到 stack component 定义中，不再单独包装 module，该 component 废弃。

## 概述

使用Baseline Component为账号工厂新创建的成员账号配置基线，包括：

- 资源规划
    - 预置标签
- 身份权限
    - RAM密码策略
    - RAM安全设置
    - 创建默认RAM角色
- 网络规划
    - 创建默认VPC、VSwitch（可选：基于IPAM创建）
    - 配置DNS PrivateZone解析
- 安全防护
    - 购买云安全中心
- 消息联系人
    - 创建新的消息联系人
    - 配置消息通知