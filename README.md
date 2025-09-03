## 结构说明




项目整体架构自下往上分为Module、Component（模块子功能）、Stack（LandingZone模块）三层：

- Module：最底层细粒度的Module，一般同时满足以下条件，可以抽象为一个Module：
    - 单产品的创建+配置
    - 使用到的TF Resource或者TF Datasource >= 2
- Component：Component可以认为是更高维度的Module，开发方式和TF Module的方式一样。LandingZone的功能模块或者子模块可以抽象为一个Component，抽象划分原则：
    - 在调用身份上存在依赖关系，比如账号工厂，配置账号基线的前提，是需要先创建出账号，用新建账号的身份配置基线，因此必须划分为两个Component：
        - account：新建账号
        - baseline：配置账号基线
    - 相互无关的子功能模块，比如：LandingZone合规审计模块，可以分为防护规则和日志投递两部分子功能，就可以抽象为多个Component：
        - guardrails：防护规则，涉及Config Rule和Control Policy，因此又可以拆分为：
            - detective：发现型防护规则，Config role
            - preventive：预防型防护规则，Control Polilcy
        - log-archive：日志投递，涉及操作审计和配置审计，因此又可以拆分为：
            - actiontrail：操作审计日志投递
            - config：配置审计日志投递
- Stack：按照LandingZone模块划分，串联Component形成LandingZone 8大模块。
