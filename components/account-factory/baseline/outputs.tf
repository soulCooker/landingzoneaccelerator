output "preset_tag" {
  description = "Output of preset tag module (if enabled)"
  value       = var.preset_tag.enabled && length(module.preset_tag) > 0 ? module.preset_tag : null
}

output "contacts" {
  description = "Output of contact module (if enabled)"
  value       = var.contact.enabled && length(module.contact) > 0 ? module.contact[0].contacts : null
}

output "ram_role" {
  description = "Output of RAM role module (if enabled)"
  value = var.ram_role.enabled && length(module.ram_role) > 0 ? {
    role_name = module.ram_role[0].role_name
    role_arn  = module.ram_role[0].role_arn
    role_id   = module.ram_role[0].role_id
  } : null
}

output "ram_security_preference" {
  description = "Output of RAM security preference module (if enabled)"
  value       = var.ram_security_preference.enabled && length(module.ram_security_preference) > 0 ? module.ram_security_preference : null
}

output "security_center" {
  description = "Output of Security Center instance (if enabled)"
  value = var.security_center.enabled && length(alicloud_threat_detection_instance.this) > 0 ? {
    id     = alicloud_threat_detection_instance.this[0].id
    status = alicloud_threat_detection_instance.this[0].status
  } : null
}

output "vpc" {
  description = "Output of vpc module (if enabled)"
  value = var.vpc.enabled && length(module.vpc) > 0 ? {
    vpc_id         = module.vpc[0].vpc_id
    vswitch_ids    = module.vpc[0].vswitch_ids
    network_acl_id = module.vpc[0].network_acl_id
  } : null
}

output "private_zone" {
  description = "Output of private zone module (if enabled)"
  value = var.private_zone.enabled && length(module.private_zone) > 0 ? {
    zone_id         = module.private_zone[0].zone_id
    zone_record_ids = module.private_zone[0].zone_record_ids
  } : null
}
