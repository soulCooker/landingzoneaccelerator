# Preset Tag module
module "preset_tag" {
  source      = "../../../modules/preset-tag"
  count       = var.preset_tag.enabled ? 1 : 0
  preset_tags = var.preset_tag.preset_tags
}

# Contact module
module "contact" {
  source                      = "../../../modules/contact"
  count                       = var.contact.enabled ? 1 : 0
  contacts                    = var.contact.contacts
  notification_recipient_mode = var.contact.notification_recipient_mode
}

# RAM Role module
module "ram_role" {
  source                      = "../../../modules/ram-role"
  count                       = var.ram_role.enabled ? 1 : 0
  role_name                   = try(var.ram_role.role_name, null)
  role_description            = try(var.ram_role.role_description, null)
  force                       = try(var.ram_role.force, true)
  max_session_duration        = try(var.ram_role.max_session_duration, 3600)
  role_requires_mfa           = try(var.ram_role.role_requires_mfa, true)
  trusted_principal_arns      = try(var.ram_role.trusted_principal_arns, [])
  trusted_services            = try(var.ram_role.trusted_services, [])
  trust_policy                = try(var.ram_role.trust_policy, null)
  managed_system_policy_names = try(var.ram_role.managed_system_policy_names, [])
  attach_admin_policy         = try(var.ram_role.attach_admin_policy, false)
  attach_readonly_policy      = try(var.ram_role.attach_readonly_policy, false)
  inline_custom_policies      = try(var.ram_role.inline_custom_policies, [])
}

# RAM Security Preference module
module "ram_security_preference" {
  source                                  = "../../../modules/ram-security-preference"
  count                                   = var.ram_security_preference.enabled ? 1 : 0
  allow_user_to_change_password           = try(var.ram_security_preference.allow_user_to_change_password, true)
  allow_user_to_login_with_passkey        = try(var.ram_security_preference.allow_user_to_login_with_passkey, true)
  allow_user_to_manage_access_keys        = try(var.ram_security_preference.allow_user_to_manage_access_keys, false)
  allow_user_to_manage_mfa_devices        = try(var.ram_security_preference.allow_user_to_manage_mfa_devices, true)
  allow_user_to_manage_personal_ding_talk = try(var.ram_security_preference.allow_user_to_manage_personal_ding_talk, true)
  enable_save_mfa_ticket                  = try(var.ram_security_preference.enable_save_mfa_ticket, true)
  login_session_duration                  = try(var.ram_security_preference.login_session_duration, 6)
  login_network_masks                     = try(var.ram_security_preference.login_network_masks, [])
  mfa_operation_for_login                 = try(var.ram_security_preference.mfa_operation_for_login, "independent")
  operation_for_risk_login                = try(var.ram_security_preference.operation_for_risk_login, "autonomous")
  verification_types                      = try(var.ram_security_preference.verification_types, [])
  password_policy                         = try(var.ram_security_preference.password_policy, null)
}

# VPC module
module "vpc" {
  source              = "../../../modules/vpc"
  count               = var.vpc.enabled ? 1 : 0
  vpc_name            = try(var.vpc.vpc_name, null)
  vpc_cidr            = try(var.vpc.vpc_cidr, null)
  vpc_description     = try(var.vpc.vpc_description, null)
  enable_ipv6         = try(var.vpc.enable_ipv6, false)
  ipv6_isp            = try(var.vpc.ipv6_isp, "BGP")
  resource_group_id   = try(var.vpc.resource_group_id, null)
  user_cidrs          = try(var.vpc.user_cidrs, null)
  ipv4_cidr_mask      = try(var.vpc.ipv4_cidr_mask, null)
  ipv4_ipam_pool_id   = try(var.vpc.ipv4_ipam_pool_id, null)
  ipv6_cidr_block     = try(var.vpc.ipv6_cidr_block, null)
  vpc_tags            = try(var.vpc.vpc_tags, {})
  vswitches           = try(var.vpc.vswitches, [])
  enable_acl          = try(var.vpc.enable_acl, false)
  acl_name            = try(var.vpc.acl_name, null)
  acl_description     = try(var.vpc.acl_description, null)
  acl_tags            = try(var.vpc.acl_tags, {})
  ingress_acl_entries = try(var.vpc.ingress_acl_entries, [])
  egress_acl_entries  = try(var.vpc.egress_acl_entries, [])
}

# Private Zone module
module "private_zone" {
  source            = "../../../modules/private-zone"
  count             = var.private_zone.enabled ? 1 : 0
  zone_name         = try(var.private_zone.zone_name, null)
  zone_remark       = try(var.private_zone.zone_remark, null)
  proxy_pattern     = try(var.private_zone.proxy_pattern, "ZONE")
  lang              = try(var.private_zone.lang, "en")
  resource_group_id = try(var.private_zone.resource_group_id, "")
  tags              = try(var.private_zone.tags, {})
  vpc_bindings      = try(var.private_zone.vpc_bindings, [])
  record_entries    = try(var.private_zone.record_entries, [])
}

# Security Center (Threat Detection) instance
resource "alicloud_threat_detection_instance" "this" {
  count                       = var.security_center.enabled ? 1 : 0
  payment_type                = var.security_center.payment_type
  version_code                = var.security_center.version_code
  period                      = try(var.security_center.period, null)
  renewal_status              = try(var.security_center.renewal_status, null)
  buy_number                  = try(var.security_center.buy_number, null)
  container_image_scan_new    = try(var.security_center.container_image_scan_new, null)
  honeypot                    = try(var.security_center.honeypot, null)
  honeypot_switch             = try(var.security_center.honeypot_switch, null)
  modify_type                 = try(var.security_center.modify_type, null)
  post_paid_flag              = try(var.security_center.post_paid_flag, null)
  post_pay_module_switch      = try(var.security_center.post_pay_module_switch, null)
  rasp_count                  = try(var.security_center.rasp_count, null)
  renew_period                = try(var.security_center.renew_period, null)
  renewal_period_unit         = try(var.security_center.renewal_period_unit, null)
  sas_anti_ransomware         = try(var.security_center.sas_anti_ransomware, null)
  sas_cspm                    = try(var.security_center.sas_cspm, null)
  sas_cspm_switch             = try(var.security_center.sas_cspm_switch, null)
  sas_sc                      = try(var.security_center.sas_sc, null)
  sas_sdk                     = try(var.security_center.sas_sdk, null)
  sas_sdk_switch              = try(var.security_center.sas_sdk_switch, null)
  sas_sls_storage             = try(var.security_center.sas_sls_storage, null)
  sas_webguard_boolean        = try(var.security_center.sas_webguard_boolean, null)
  sas_webguard_order_num      = try(var.security_center.sas_webguard_order_num, null)
  subscription_type           = try(var.security_center.subscription_type, null)
  threat_analysis             = try(var.security_center.threat_analysis, null)
  threat_analysis_flow        = try(var.security_center.threat_analysis_flow, null)
  threat_analysis_sls_storage = try(var.security_center.threat_analysis_sls_storage, null)
  threat_analysis_switch      = try(var.security_center.threat_analysis_switch, null)
  threat_analysis_switch1     = try(var.security_center.threat_analysis_switch1, null)
  v_core                      = try(var.security_center.v_core, null)
  vul_count                   = try(var.security_center.vul_count, null)
  vul_switch                  = try(var.security_center.vul_switch, null)
}
