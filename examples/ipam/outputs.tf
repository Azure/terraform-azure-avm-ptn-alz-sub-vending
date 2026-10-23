output "virtual_network_address_spaces" {
  description = "The IPAM-allocated address spaces of the created virtual networks."
  value       = module.sub_vending.virtual_network_address_spaces
}

output "virtual_network_resource_ids" {
  description = "The resource IDs of the created virtual networks."
  value       = module.sub_vending.virtual_network_resource_ids
}

output "virtual_network_subnet_address_prefixes" {
  description = "The IPAM-allocated subnet address prefixes, keyed by virtual network and subnet."
  value       = module.sub_vending.virtual_network_subnet_address_prefixes
}
