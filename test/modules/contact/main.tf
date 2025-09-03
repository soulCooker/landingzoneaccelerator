provider "alicloud" {
  region = "cn-hangzhou"

}

module "contact" {
  source = "../../../modules/contact"

  contacts = [
    {
      name     = "张三"
      email    = "zhangsan@example.com"
      mobile   = "13800000000"
      position = "Technical Director"
    },
    {
      name     = "李四"
      email    = "lisi@example.com"
      mobile   = "13900000000"
      position = "Maintenance Director"

    }
  ]

  notification_recipient_mode = "append"

}


output "contacts" {
  value = module.contact.contacts
}
