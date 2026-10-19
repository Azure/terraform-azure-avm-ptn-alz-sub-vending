output "resource_id" {
  description = "The created virtual network resource IDs, expressed as a map."
  value = {
    for k, v in module.virtual_networks : k => v.resource_id
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
