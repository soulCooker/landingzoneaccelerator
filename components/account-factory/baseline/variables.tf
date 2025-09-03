variable "preset_tag" {
  description = "Preset tag module config, including enabled and parameters."
  type = object({
    enabled = bool
    preset_tags = list(object({
      key    = string
      values = list(string)
    }))
  })
  default = {
    enabled     = false
    preset_tags = []
  }
}

variable "contact" {
  description = "Contact module config, including enabled and parameters."
  type = object({
    enabled = bool
    contacts = list(object({
      name     = string
      email    = string
      mobile   = optional(string, "0000")
      position = string
    }))
    notification_recipient_mode = string
  })
  default = {
    enabled                     = false
    contacts                    = []
    notification_recipient_mode = "append"
  }
}

variable "ram_role" {
  description = "RAM role module config, including enabled and parameters."
  type = object({
    enabled                     = bool
    role_name                   = optional(string)
    role_description            = optional(string)
    force                       = optional(bool, true)
    max_session_duration        = optional(number, 3600)
    role_requires_mfa           = optional(bool, true)
    trusted_principal_arns      = optional(list(string), [])
    trusted_services            = optional(list(string), [])
    trust_policy                = optional(string)
    managed_system_policy_names = optional(list(string), [])
    attach_admin_policy         = optional(bool, false)
    attach_readonly_policy      = optional(bool, false)
    inline_custom_policies = optional(list(object({
      policy_name     = string
      policy_document = string
      description     = optional(string)
      force           = optional(bool, true)
    })), [])
  })
  default = {
    enabled = false
  }
}

variable "ram_security_preference" {
  description = "RAM security preference module config, including enabled and parameters."
  type = object({
    enabled                                 = bool
    allow_user_to_change_password           = optional(bool, true)
    allow_user_to_login_with_passkey        = optional(bool, true)
    allow_user_to_manage_access_keys        = optional(bool, false)
    allow_user_to_manage_mfa_devices        = optional(bool, true)
    allow_user_to_manage_personal_ding_talk = optional(bool, true)
    enable_save_mfa_ticket                  = optional(bool, true)
    login_session_duration                  = optional(number, 6)
    login_network_masks                     = optional(list(string), [])
    mfa_operation_for_login                 = optional(string, "independent")
    operation_for_risk_login                = optional(string, "autonomous")
    verification_types                      = optional(set(string), [])
    password_policy = optional(object({
      minimum_password_length              = optional(number)
      require_lowercase_characters         = optional(bool)
      require_numbers                      = optional(bool)
      require_uppercase_characters         = optional(bool)
      require_symbols                      = optional(bool)
      max_password_age                     = optional(number)
      password_reuse_prevention            = optional(number)
      max_login_attempts                   = optional(number)
      hard_expiry                          = optional(bool)
      password_not_contain_user_name       = optional(bool)
      minimum_password_different_character = optional(number)
    }), null)
  })
  default = {
    enabled = false
  }
}

variable "security_center" {
  description = "Security Center module config, including enabled and all parameters."
  type = object({
    enabled                     = bool
    payment_type                = string
    version_code                = string
    period                      = optional(number)
    renewal_status              = optional(string)
    buy_number                  = optional(string)
    container_image_scan_new    = optional(string)
    honeypot                    = optional(string)
    honeypot_switch             = optional(string)
    modify_type                 = optional(string)
    post_paid_flag              = optional(number)
    post_pay_module_switch      = optional(string)
    rasp_count                  = optional(string)
    renew_period                = optional(number)
    renewal_period_unit         = optional(string)
    sas_anti_ransomware         = optional(string)
    sas_cspm                    = optional(string)
    sas_cspm_switch             = optional(string)
    sas_sc                      = optional(bool)
    sas_sdk                     = optional(string)
    sas_sdk_switch              = optional(string)
    sas_sls_storage             = optional(string)
    sas_webguard_boolean        = optional(string)
    sas_webguard_order_num      = optional(string)
    subscription_type           = optional(string)
    threat_analysis             = optional(string)
    threat_analysis_flow        = optional(string)
    threat_analysis_sls_storage = optional(string)
    threat_analysis_switch      = optional(string)
    threat_analysis_switch1     = optional(string)
    v_core                      = optional(string)
    vul_count                   = optional(string)
    vul_switch                  = optional(string)
  })
  default = {
    enabled      = false
    payment_type = "Subscription"
    version_code = "enterprise"
  }
  validation {
    condition     = contains(["PayAsYouGo", "Subscription"], var.security_center.payment_type)
    error_message = "payment_type must be 'PayAsYouGo' or 'Subscription'"
  }
  validation {
    condition     = var.security_center.version_code != null && length(var.security_center.version_code) > 0
    error_message = "version_code is required and must not be empty."
  }
  validation {
    condition     = var.security_center.renewal_status == null || can(contains(["AutoRenewal", "ManualRenewal"], var.security_center.renewal_status))
    error_message = "renewal_status must be 'AutoRenewal' or 'ManualRenewal' if set."
  }
  validation {
    condition     = var.security_center.modify_type == null || can(contains(["Upgrade", "Downgrade"], var.security_center.modify_type))
    error_message = "modify_type must be 'Upgrade' or 'Downgrade' if set."
  }
  validation {
    condition     = var.security_center.renewal_period_unit == null || can(contains(["M", "Y"], var.security_center.renewal_period_unit))
    error_message = "renewal_period_unit must be 'M' or 'Y' if set."
  }
  validation {
    condition     = var.security_center.honeypot_switch == null || can(contains(["1", "2"], var.security_center.honeypot_switch))
    error_message = "honeypot_switch must be '1' or '2' if set."
  }
  validation {
    condition     = var.security_center.sas_cspm_switch == null || can(contains(["0", "1"], var.security_center.sas_cspm_switch))
    error_message = "sas_cspm_switch must be '0' or '1' if set."
  }
  validation {
    condition     = var.security_center.sas_sdk_switch == null || can(contains(["0", "1"], var.security_center.sas_sdk_switch))
    error_message = "sas_sdk_switch must be '0' or '1' if set."
  }
  validation {
    condition     = var.security_center.sas_webguard_boolean == null || can(contains(["0", "1"], var.security_center.sas_webguard_boolean))
    error_message = "sas_webguard_boolean must be '0' or '1' if set."
  }
  validation {
    condition     = var.security_center.threat_analysis_switch == null || can(contains(["0", "1"], var.security_center.threat_analysis_switch))
    error_message = "threat_analysis_switch must be '0' or '1' if set."
  }
  validation {
    condition     = var.security_center.threat_analysis_switch1 == null || can(contains(["0", "1"], var.security_center.threat_analysis_switch1))
    error_message = "threat_analysis_switch1 must be '0' or '1' if set."
  }
  validation {
    condition     = var.security_center.vul_switch == null || can(contains(["0", "1"], var.security_center.vul_switch))
    error_message = "vul_switch must be '0' or '1' if set."
  }
}

variable "vpc" {
  description = "VPC module config, including enabled and parameters."
  type = object({
    enabled           = bool
    vpc_name          = optional(string)
    vpc_cidr          = optional(string)
    vpc_description   = optional(string)
    enable_ipv6       = optional(bool, false)
    ipv6_isp          = optional(string, "BGP")
    resource_group_id = optional(string)
    user_cidrs        = optional(list(string))
    ipv4_cidr_mask    = optional(number)
    ipv4_ipam_pool_id = optional(string)
    ipv6_cidr_block   = optional(string)
    vpc_tags          = optional(map(string), {})
    vswitches = optional(list(object({
      cidr_block           = string
      zone_id              = string
      vswitch_name         = optional(string)
      description          = optional(string)
      enable_ipv6          = optional(bool)
      ipv6_cidr_block_mask = optional(number)
      tags                 = optional(map(string))
    })), [])
    enable_acl      = optional(bool, false)
    acl_name        = optional(string)
    acl_description = optional(string)
    acl_tags        = optional(map(string), {})
    ingress_acl_entries = optional(list(object({
      protocol               = string
      port                   = string
      source_cidr_ip         = string
      policy                 = optional(string, "accept")
      description            = optional(string)
      network_acl_entry_name = optional(string)
      ip_version             = optional(string, "IPV4")
    })), [])
    egress_acl_entries = optional(list(object({
      protocol               = string
      port                   = string
      destination_cidr_ip    = string
      policy                 = optional(string, "accept")
      description            = optional(string)
      network_acl_entry_name = optional(string)
      ip_version             = optional(string, "IPV4")
    })), [])
  })
  default = {
    enabled   = false
    vswitches = []
  }
}

variable "private_zone" {
  description = "Private Zone module config, including enabled and all parameters."
  type = object({
    enabled           = bool
    zone_name         = optional(string)
    zone_remark       = optional(string)
    proxy_pattern     = optional(string, "ZONE")
    lang              = optional(string, "en")
    resource_group_id = optional(string, "")
    tags              = optional(map(string), {})
    vpc_bindings = optional(list(object({
      vpc_id    = string
      region_id = optional(string)
    })), [])
    record_entries = optional(list(object({
      name     = string
      type     = string
      value    = string
      ttl      = optional(number, 60)
      lang     = optional(string, "en")
      priority = optional(number, 1)
      remark   = optional(string, "")
      status   = optional(string, "ENABLE")
    })), [])
  })
  default = {
    enabled           = false
    vpc_bindings      = []
    record_entries    = []
    tags              = {}
    proxy_pattern     = "ZONE"
    lang              = "en"
    resource_group_id = ""
  }
}

