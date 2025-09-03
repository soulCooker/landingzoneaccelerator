data "alicloud_account" "cen_account" {
  provider = alicloud.cen
}

data "alicloud_account" "vpc_account" {
  provider = alicloud.vpc
}

data "alicloud_ram_roles" "cen_service_role" {
  provider   = alicloud.vpc
  name_regex = "^AliyunServiceRoleForCEN$"
}

resource "alicloud_resource_manager_service_linked_role" "cen_service_role" {
  count        = length(data.alicloud_ram_roles.cen_service_role.roles) == 0 ? 1 : 0
  provider     = alicloud.vpc
  service_name = "cen.aliyuncs.com"
}

locals {
  auth_required = data.alicloud_account.cen_account.id != data.alicloud_account.vpc_account.id ? true : false
}

resource "alicloud_cen_instance_grant" "cen_instance_grant" {
  provider          = alicloud.vpc
  count             = local.auth_required ? 1 : 0
  cen_id            = var.cen_instance_id
  cen_owner_id      = data.alicloud_account.cen_account.id
  child_instance_id = var.vpc_id

  depends_on = [alicloud_resource_manager_service_linked_role.cen_service_role]
}

resource "alicloud_cen_transit_router_vpc_attachment" "vpc_attachment" {
  provider          = alicloud.cen
  cen_id            = var.cen_instance_id
  transit_router_id = var.cen_transit_router_id
  vpc_id            = var.vpc_id
  vpc_owner_id      = data.alicloud_account.vpc_account.id

  zone_mappings {
    zone_id    = var.primary_vswitch.zone_id
    vswitch_id = var.primary_vswitch.vswitch_id
  }
  zone_mappings {
    zone_id    = var.secondary_vswitch.zone_id
    vswitch_id = var.secondary_vswitch.vswitch_id
  }



  transit_router_vpc_attachment_name    = var.transit_router_attachment_name
  transit_router_attachment_description = var.transit_router_attachment_description

  timeouts {
    create = "15m"
    update = "15m"
    delete = "30m"
  }

  depends_on = [
    alicloud_resource_manager_service_linked_role.cen_service_role, alicloud_cen_instance_grant.cen_instance_grant
  ]
}

resource "alicloud_cen_transit_router_route_table_association" "route_table_association" {
  provider                      = alicloud.cen
  count                         = var.route_table_association_enabled == true ? 1 : 0
  transit_router_route_table_id = var.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_table_propagation" "route_table_propagation" {
  provider                      = alicloud.cen
  count                         = var.route_table_propagation_enabled == true ? 1 : 0
  transit_router_route_table_id = var.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
}
