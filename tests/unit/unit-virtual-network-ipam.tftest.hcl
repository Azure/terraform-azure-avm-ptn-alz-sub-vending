# Virtual Network IPAM Pool Tests
# Tests IPAM pool allocation path for VNets and subnets

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "modtm" {}

mock_provider "random" {}

mock_provider "time" {}
mock_provider "terraform" {}

variables {
  location         = "uksouth"
  subscription_id  = "00000000-0000-0000-0000-000000000000"
  enable_telemetry = false
}

# Test: VNet with IPAM pools (no address_space)
run "valid_vnet_with_ipam_pools" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      ipam_vnet = {
        name                         = "ipam-vnet"
        resource_group_name_existing = "test-rg"
        ipam_pools = [{
          id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkManagers/test-nm/ipamPools/test-pool"
          prefix_length = 24
        }]
      }
    }
  }

  assert {
    condition     = length(keys(module.virtualnetwork[0].virtual_network_resource_ids)) == 1
    error_message = "Expected exactly 1 virtual network to be created"
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# Test: VNet with IPAM pools and IPAM subnets
run "valid_vnet_with_ipam_subnets" {
  command = apply

  override_resource {
    target = module.virtualnetwork[0].module.virtual_networks["ipam_vnet"].azapi_resource.vnet
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/ipam-vnet"
      output = {
        properties = {
          addressSpace = {
            addressPrefixes = ["10.10.0.0/24"]
          }
        }
      }
    }
  }

  override_resource {
    target = module.virtualnetwork[0].module.virtual_networks["ipam_vnet"].module.subnet["workload"].azapi_resource.subnet_ipam[0]
    values = {
      output = {
        properties = {
          addressPrefixes = ["10.10.0.0/26"]
        }
      }
    }
  }

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      ipam_vnet = {
        name                         = "ipam-vnet"
        resource_group_name_existing = "test-rg"
        ipam_pools = [{
          id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkManagers/test-nm/ipamPools/test-pool"
          prefix_length = 24
        }]
        subnets = {
          workload = {
            name = "subnet-workload"
            ipam_pools = [{
              pool_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkManagers/test-nm/ipamPools/test-pool"
              prefix_length = 26
            }]
          }
        }
      }
    }
  }

  assert {
    condition     = length(keys(module.virtualnetwork[0].virtual_network_resource_ids)) == 1
    error_message = "Expected exactly 1 virtual network to be created"
  }
  assert {
    condition     = toset(output.virtual_network_address_spaces["ipam_vnet"]) == toset(["10.10.0.0/24"])
    error_message = "Expected the allocated VNet CIDR from the resource response, not the IPAM pool input."
  }

  assert {
    condition     = toset(output.virtual_network_subnet_address_prefixes["ipam_vnet"]["workload"]) == toset(["10.10.0.0/26"])
    error_message = "Expected the allocated subnet CIDR from the resource response."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# Test: Traditional address_space still works (backward compatibility)
run "valid_vnet_with_address_space" {
  command = apply

  override_resource {
    target = module.virtualnetwork[0].module.virtual_networks["traditional"].azapi_resource.vnet
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/traditional-vnet"
    }
  }

  override_resource {
    target = module.virtualnetwork[0].module.virtual_networks["traditional"].module.subnet["workload"].azapi_resource.subnet[0]
    values = {
      output = {
        properties = {
          addressPrefixes = ["10.0.1.0/24"]
        }
      }
    }
  }

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      traditional = {
        name                         = "traditional-vnet"
        address_space                = ["10.0.0.0/16"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name             = "subnet-workload"
            address_prefixes = ["10.0.1.0/24"]
          }
        }
      }
    }
  }

  assert {
    condition     = length(keys(module.virtualnetwork[0].virtual_network_resource_ids)) == 1
    error_message = "Expected exactly 1 virtual network to be created"
  }
  assert {
    condition     = toset(output.virtual_network_address_spaces["traditional"]) == toset(["10.0.0.0/16"])
    error_message = "Expected the static VNet address space at the root output."
  }

  assert {
    condition     = toset(output.virtual_network_subnet_address_prefixes["traditional"]["workload"]) == toset(["10.0.1.0/24"])
    error_message = "Expected the static subnet address prefixes at the root output."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}
