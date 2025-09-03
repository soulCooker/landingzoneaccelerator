output "kms_instance_id" {
  value = module.kms.kms_instance_id
}

output "kms_instance_status" {
  value = module.kms.kms_instance_status
}

output "kms_instance_name" {
  value = module.kms.kms_instance_name
}

output "vpc_id" {
  value = module.kms.vpc_id
}

output "vswitch_id" {
  value = module.kms.vswitch_id
}

output "advanced_kms_instance_id" {
  value = module.kms_advanced.kms_instance_id
}

output "advanced_kms_instance_status" {
  value = module.kms_advanced.kms_instance_status
}

output "advanced_kms_instance_name" {
  value = module.kms_advanced.kms_instance_name
}

output "advanced_vpc_id" {
  value = module.kms_advanced.vpc_id
}

output "advanced_vswitch_id" {
  value = module.kms_advanced.vswitch_id
}