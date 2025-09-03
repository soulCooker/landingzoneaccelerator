terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.253.0"
      configuration_aliases = [alicloud.cen, alicloud.dmz]
    }
  }
  required_version = ">= 0.13"
}
