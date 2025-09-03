data "alicloud_resource_manager_resource_directories" "default" {
  count = length([for p in var.control_policies : p if p.attach_to_root]) > 0 ? 1 : 0
}

resource "alicloud_resource_manager_control_policy" "default" {
  count = length(var.control_policies)

  control_policy_name = var.control_policies[count.index].name
  description         = var.control_policies[count.index].description
  policy_document     = var.control_policies[count.index].policy_document
  effect_scope        = "RAM"
}

locals {
  # Generate policy attachments for both root and specific targets
  policy_attachments = flatten([
    for i, policy in var.control_policies : [
      for target_id in (policy.attach_to_root ? 
        [data.alicloud_resource_manager_resource_directories.default[0].directories[0].root_folder_id] : 
        policy.target_ids
      ) : {
        policy_index = i
        policy_id    = alicloud_resource_manager_control_policy.default[i].id
        target_id    = target_id
      }
    ]
  ])
}

resource "alicloud_resource_manager_control_policy_attachment" "default" {
  count = length(local.policy_attachments)

  policy_id = local.policy_attachments[count.index].policy_id
  target_id = local.policy_attachments[count.index].target_id

  depends_on = [
    alicloud_resource_manager_control_policy.default,
    data.alicloud_resource_manager_resource_directories.default
  ]
}