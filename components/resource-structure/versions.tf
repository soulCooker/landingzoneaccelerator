terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = ">= 1.253.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
  required_version = ">= 0.13"
}
