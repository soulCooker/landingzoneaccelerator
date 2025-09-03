provider "alicloud" {
  region = "cn-hangzhou"

}

module "private_zone" {
  source = "../../../modules/private-zone"

  zone_name         = "example.com"
  zone_remark       = "PrivateZone_testenv01-2024.06.01"
  proxy_pattern     = "ZONE"
  lang              = "en"
  resource_group_id = null
  tags = {
    env     = "test"
    project = "landing-zone"

  }

  vpc_bindings = [
    { vpc_id = "vpc-xxxxxxxxxxxxxxxxxxxx" },
    { vpc_id = "vpc-yyyyyyyyyyyyyyyyyyyy", region_id = "cn-beijing"
    }
  ]

  record_entries = [
    {
      name   = "www"
      type   = "A"
      value  = "192.168.0.1"
      ttl    = 60
      lang   = "en"
      remark = "TestA_record"
      status = "ENABLE"
    },
    {
      name     = "mail"
      type     = "MX"
      value    = "mail.example.com"
      ttl      = 60
      lang     = "en"
      priority = 10
      remark   = "TestMX_record"
      status   = "ENABLE"

    }
  ]

}


output "zone_id" {
  value = module.private_zone.zone_id
}

output "zone_record_ids" {
  value = module.private_zone.zone_record_ids
}
