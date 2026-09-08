resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.this
  body = {
    properties = {
      addressPrefix    = var.address_prefix
      nextHopIpAddress = var.next_hop_in_ip_address
      nextHopType      = var.next_hop_type
    }
  }
  replace_triggers_refs  = []
  response_export_values = []
  retry                  = var.retry

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
