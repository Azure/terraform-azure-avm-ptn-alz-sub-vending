resource "azapi_resource" "this" {
  type      = var.resource_types.this
  name      = var.name
  parent_id = var.parent_id

  body = {
    properties = {
      access                               = var.access
      description                          = var.description
      destinationAddressPrefix             = var.destination_address_prefix
      destinationAddressPrefixes           = var.destination_address_prefixes
      destinationApplicationSecurityGroups = var.destination_application_security_group_ids != null ? [for asg in var.destination_application_security_group_ids : { id = asg }] : null
      destinationPortRange                 = var.destination_port_range
      destinationPortRanges                = var.destination_port_ranges
      direction                            = var.direction
      priority                             = var.priority
      protocol                             = var.protocol
      sourceAddressPrefix                  = var.source_address_prefix
      sourceAddressPrefixes                = var.source_address_prefixes
      sourceApplicationSecurityGroups      = var.source_application_security_group_ids != null ? [for asg in var.source_application_security_group_ids : { id = asg }] : null
      sourcePortRange                      = var.source_port_range
      sourcePortRanges                     = var.source_port_ranges
    }
  }

  replace_triggers_refs = []

  response_export_values = []

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
