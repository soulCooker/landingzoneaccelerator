provider "alicloud" {
  region = "cn-hangzhou"
}

module "ram_security_preference" {
  source = "../../../modules/ram-security-preference"

  allow_user_to_change_password       = true
  allow_user_to_login_with_passkey    = true
  allow_user_to_manage_access_keys    = false
  allow_user_to_manage_mfa_devices    = true
  allow_user_to_manage_personal_ding_talk = true
  enable_save_mfa_ticket              = true
  login_session_duration              = 12
  login_network_masks                 = []
  mfa_operation_for_login             = "independent"
  operation_for_risk_login            = "autonomous"
  verification_types                  = []

  password_policy = {
    minimum_password_length              = 10
    require_lowercase_characters         = true
    require_numbers                      = true
    require_uppercase_characters         = true
    require_symbols                      = false
    max_password_age                     = 90
    password_reuse_prevention            = 3
    max_login_attempts                   = 5
    hard_expiry                          = false
    password_not_contain_user_name       = false
    minimum_password_different_character = 0
  }
}
