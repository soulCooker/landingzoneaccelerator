provider "alicloud" {
  region = "cn-hangzhou"
}

module "preset_tag" {
  source = "../../../modules/preset-tag"

  preset_tags = [
    {
      key    = "environment"
      values = ["dev", "test", "prod"]
    },
    {
      key    = "project"
      values = ["project1", "project2"]
    }
  ]
}
