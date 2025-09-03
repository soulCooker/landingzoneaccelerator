provider "alicloud" {
  region = "cn-shanghai"
}

module "detective_guardrails" {
  source = "../../../../components/guardrails/detective"

  use_existing_aggregator = false
  aggregator_name         = "LandingZoneConfigAggregator"
  enable_compliance_pack  = true
  compliance_pack_name    = "Resource Stability Best Practices v2"
  risk_level              = 1
  template_based_rules = [
    {
      rule_name                       = "ECSInstanceNoPublicIP"
      description                     = "Ensure ECS instances do not have public IP addresses"
      source_template_id              = "ecs-instance-no-public-ip"
      maximum_execution_frequency     = "One_Hour"
      scope_compliance_resource_types = ["ACS::ECS::Instance"]
      add_to_compliance_pack          = true # 加入合规包
    },
    {
      rule_name                       = "OSSBucketPublicReadProhibited"
      description                     = "Ensure OSS buckets do not allow public read"
      source_template_id              = "oss-bucket-public-read-prohibited"
      maximum_execution_frequency     = "Six_Hours"
      scope_compliance_resource_types = ["ACS::OSS::Bucket"]
      risk_level                      = 2
      trigger_types                   = "ScheduledNotification"
      add_to_compliance_pack          = true # 加入合规包
    },
    {
      rule_name                       = "ActionTrailEnabled"
      description                     = "Ensure ActionTrail is enabled for audit logging"
      source_template_id              = "actiontrail-enabled"
      scope_compliance_resource_types = ["ACS::ActionTrail::Trail"]
      trigger_types                   = "ScheduledNotification"
      add_to_compliance_pack          = false # 独立规则，不加入合规包
    },
    {
      rule_name                       = "OSSBucketVersioningEnabled"
      description                     = "Ensure OSS bucket versioning is enabled"
      source_template_id              = "oss-bucket-versioning-enabled"
      scope_compliance_resource_types = ["ACS::OSS::Bucket"]
      trigger_types                   = "ScheduledNotification"
      risk_level                      = 2
      add_to_compliance_pack          = false # 独立规则，不加入合规包
    }
  ]

  # Custom FC rules are commented out as test environment lacks required Function Compute resources
  custom_fc_rules = []
}

output "aggregator_id" {
  value = module.detective_guardrails.aggregator_id
}

output "compliance_pack_id" {
  value = module.detective_guardrails.compliance_pack_id
}

output "rule_ids" {
  value = module.detective_guardrails.rule_ids
}

