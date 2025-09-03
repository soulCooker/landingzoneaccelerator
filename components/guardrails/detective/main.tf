# Enable Config service
module "enable_config_service" {
  source = "../../../modules/config-configuration-recorder"
}

# Create Config aggregator for rule management (only if not using existing aggregator)
resource "alicloud_config_aggregator" "default" {
  count           = var.use_existing_aggregator ? 0 : 1
  aggregator_name = var.aggregator_name
  aggregator_type = "RD"
  description     = var.aggregator_description

  depends_on = [module.enable_config_service]
}

locals {
  aggregator_id = var.use_existing_aggregator ? var.existing_aggregator_id : alicloud_config_aggregator.default[0].id
}

resource "alicloud_config_aggregate_config_rule" "template" {
  count                       = length(var.template_based_rules)
  aggregate_config_rule_name  = var.template_based_rules[count.index].rule_name
  description                 = var.template_based_rules[count.index].description
  source_identifier           = var.template_based_rules[count.index].source_template_id
  source_owner                = "ALIYUN"
  input_parameters            = var.template_based_rules[count.index].input_parameters
  maximum_execution_frequency = var.template_based_rules[count.index].maximum_execution_frequency
  resource_types_scope        = var.template_based_rules[count.index].scope_compliance_resource_types
  risk_level                  = var.template_based_rules[count.index].risk_level
  config_rule_trigger_types   = var.template_based_rules[count.index].trigger_types
  aggregator_id               = local.aggregator_id
  tag_key_scope               = var.template_based_rules[count.index].tag_key_scope
  tag_value_scope             = var.template_based_rules[count.index].tag_value_scope
  region_ids_scope            = var.template_based_rules[count.index].region_ids_scope
  exclude_resource_ids_scope  = var.template_based_rules[count.index].exclude_resource_ids_scope
  resource_group_ids_scope    = length(var.template_based_rules[count.index].resource_group_ids_scope) > 0 ? join(",", var.template_based_rules[count.index].resource_group_ids_scope) : null
}

# Create Function Compute based custom rules
resource "alicloud_config_aggregate_config_rule" "custom_fc" {
  count                       = length(var.custom_fc_rules)
  aggregate_config_rule_name  = var.custom_fc_rules[count.index].rule_name
  description                 = var.custom_fc_rules[count.index].description
  source_identifier           = var.custom_fc_rules[count.index].source_arn
  source_owner                = "CUSTOM_FC"
  input_parameters            = var.custom_fc_rules[count.index].input_parameters
  maximum_execution_frequency = var.custom_fc_rules[count.index].maximum_execution_frequency
  resource_types_scope        = var.custom_fc_rules[count.index].scope_compliance_resource_types
  risk_level                  = var.custom_fc_rules[count.index].risk_level
  config_rule_trigger_types   = var.custom_fc_rules[count.index].trigger_types
  aggregator_id               = local.aggregator_id
  tag_key_scope               = var.custom_fc_rules[count.index].tag_key_scope
  tag_value_scope             = var.custom_fc_rules[count.index].tag_value_scope
  region_ids_scope            = var.custom_fc_rules[count.index].region_ids_scope
  exclude_resource_ids_scope  = var.custom_fc_rules[count.index].exclude_resource_ids_scope
  resource_group_ids_scope    = length(var.custom_fc_rules[count.index].resource_group_ids_scope) > 0 ? join(",", var.custom_fc_rules[count.index].resource_group_ids_scope) : null
}

# Create compliance pack containing selected rules
resource "alicloud_config_aggregate_compliance_pack" "default" {
  count                          = var.enable_compliance_pack ? 1 : 0
  aggregate_compliance_pack_name = var.compliance_pack_name
  description                    = "Compliance pack for Landing Zone"
  risk_level                     = var.risk_level
  aggregator_id                  = local.aggregator_id

  dynamic "config_rule_ids" {
    for_each = var.enable_compliance_pack ? concat(
      [
        for i, r in var.template_based_rules : alicloud_config_aggregate_config_rule.template[i].config_rule_id
        if try(r.add_to_compliance_pack, true)
      ],
      [
        for i, r in var.custom_fc_rules : alicloud_config_aggregate_config_rule.custom_fc[i].config_rule_id
        if try(r.add_to_compliance_pack, true)
      ]
    ) : []

    content {
      config_rule_id = config_rule_ids.value
    }
  }

  depends_on = [
    alicloud_config_aggregate_config_rule.template,
    alicloud_config_aggregate_config_rule.custom_fc
  ]
}
