output "resource_id" {
  description = "The created virtual network resource IDs, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.resource_id
  }
}

output "virtual_network_address_spaces" {
  description = "The created virtual network resource address spaces, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.address_spaces
  }
}

output "virtual_network_resource_ids" {
  description = "The created virtual network resource IDs, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.resource_id
  }
}
