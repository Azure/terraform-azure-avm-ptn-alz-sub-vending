resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.this
  body = {
    properties = {}
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

module "security_rule" {
  source   = "./modules/security-rule"
  for_each = var.security_rules

  access                                     = each.value.access
  direction                                  = each.value.direction
  name                                       = each.value.name
  parent_id                                  = azapi_resource.this.id
  priority                                   = each.value.priority
  protocol                                   = each.value.protocol
  description                                = each.value.description
  destination_address_prefix                 = each.value.destination_address_prefix
  destination_address_prefixes               = each.value.destination_address_prefixes
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
  destination_port_range                     = each.value.destination_port_range
  destination_port_ranges                    = each.value.destination_port_ranges
  resource_types                             = { this = var.resource_types.security_rule }
  retry                                      = var.retry
  source_address_prefix                      = each.value.source_address_prefix
  source_address_prefixes                    = each.value.source_address_prefixes
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  source_port_range                          = each.value.source_port_range
  source_port_ranges                         = each.value.source_port_ranges
  timeouts                                   = var.timeouts
}
