resource "alicloud_config_configuration_recorder" "this" {
  # This param is deprecated. Create aggregator will uprade to enterprise edition automatically,
  # and setting this param will cause trouble when importing state, so we ignore it.
  # enterprise_edition = true

  lifecycle {
    ignore_changes = [
      resource_types,
      enterprise_edition
    ]
  }
}
