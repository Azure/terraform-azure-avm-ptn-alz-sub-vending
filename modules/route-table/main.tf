resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.this
  body = {
    properties = {
      disableBgpRoutePropagation = !var.bgp_route_propagation_enabled
    }
  }
  retry = var.retry
  tags  = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

module "route" {
  source   = "./modules/route"
  for_each = var.routes

  address_prefix         = each.value.address_prefix
  name                   = each.value.name
  next_hop_type          = each.value.next_hop_type
  parent_id              = azapi_resource.this.id
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  resource_types         = { this = var.resource_types.route }
  retry                  = var.retry
  timeouts               = var.timeouts
}
