resource "azapi_resource" "this" {
  type      = var.resource_types.this
  name      = var.name
  parent_id = var.parent_id
  location  = var.location

  body = {
    properties = {
      disableBgpRoutePropagation = !var.bgp_route_propagation_enabled
    }
  }

  tags = var.tags

  retry = var.retry

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

  name      = each.value.name
  parent_id = azapi_resource.this.id

  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address

  resource_types = { this = var.resource_types.route }
  retry          = var.retry
  timeouts       = var.timeouts
}
