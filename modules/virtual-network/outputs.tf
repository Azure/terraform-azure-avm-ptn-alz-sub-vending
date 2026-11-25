output "address_spaces" {
  description = "Virtual network address spaces, including IPAM-allocated ranges, keyed by the virtual_networks input map."
  value = {
    for vnet_key, vnet in module.virtual_networks : vnet_key => vnet.address_spaces
  }
}

output "resource_id" {
  description = "The created virtual network resource IDs, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.resource_id
  }
}

output "subnet_address_prefixes" {
  description = "Subnet address prefixes, including IPAM-allocated ranges, keyed first by virtual network key and then by subnet key."
  value = {
    for vnet_key, vnet in module.virtual_networks : vnet_key => {
      for subnet_key, subnet in vnet.subnets : subnet_key => subnet.address_prefixes
    }
  }
}

output "subnet_resource_ids" {
  description = "Subnet resource IDs per VNet key, expressed as a map."
  value = {
    for vnet_key, vnet_mod in module.virtual_networks :
    vnet_key => {
      for subnet_key, subnet in vnet_mod.subnets :
      subnet_key => subnet.resource_id
    }
  }
}

output "virtual_network_resource_ids" {
  description = "The created virtual network resource IDs, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.resource_id
  }
}
