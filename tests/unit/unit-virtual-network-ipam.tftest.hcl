# Virtual Network IPAM Pool Tests
# Tests IPAM pool allocation path for VNets and subnets

mock_provider "azurerm" {}
mock_provider "azapi" {
  source = "Azure/azapi"
}
mock_provider "modtm" {
  source = "Azure/modtm"
}
mock_provider "time" {}

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
}

# Test: VNet with IPAM pools and IPAM subnets
run "valid_vnet_with_ipam_subnets" {
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
}

# Test: Traditional address_space still works (backward compatibility)
run "valid_vnet_with_address_space" {
  command = plan

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
}
