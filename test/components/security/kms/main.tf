# Test for KMS component

terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
  }
}

# Test 1: Create a basic KMS instance
module "kms" {
  source = "../../../../components/security/kms"

  create_kms_instance = true
  kms_instance_name   = "test-kms-instance"
  kms_instance_spec   = "1000"
  product_version     = "3"
  kms_key_amount      = 1000
  create_vpc          = true
  vpc_name            = "test-kms-vpc"
  vpc_cidr_block      = "10.0.0.0/8"
  vswitch_cidr_block  = "10.0.0.0/24"
  availability_zone   = "cn-hangzhou-g"
}

# Test 2: Create an Advanced KMS instance
module "kms_advanced" {
  source = "../../../../components/security/kms"

  create_kms_instance = true
  kms_instance_name   = "test-advanced-kms-instance"
  kms_instance_spec   = "2000"
  product_version     = "3"
  kms_key_amount      = 2000
  create_vpc          = true
  vpc_name            = "test-advanced-kms-vpc"
  vpc_cidr_block      = "172.16.0.0/12"
  vswitch_cidr_block  = "172.16.0.0/24"
  availability_zone   = "cn-hangzhou-g"
}