# Virtual Network Module Basic Tests
# Tests basic VNet creation without deploying

mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "time" {}

variables {
  location         = "uksouth"
  subscription_id  = "00000000-0000-0000-0000-000000000000"
  enable_telemetry = false
}

run "valid_two_vnets" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      primary = {
        name                         = "primary-vnet"
        address_space                = ["192.168.0.0/24"]
        location                     = "westeurope"
        resource_group_name_existing = "primary-rg"
      }
      secondary = {
        name                         = "secondary-vnet"
        address_space                = ["192.168.1.0/24"]
        location                     = "northeurope"
        resource_group_name_existing = "secondary-rg"
      }
    }
  }

  assert {
    condition     = length(keys(module.virtualnetwork[0].virtual_network_resource_ids)) == 2
    error_message = "Expected exactly 2 virtual networks to be created, got ${length(keys(module.virtualnetwork[0].virtual_network_resource_ids))}"
  }

  assert {
    condition     = contains(keys(module.virtualnetwork[0].virtual_network_resource_ids), "primary")
    error_message = "Expected 'primary' virtual network to be present in output"
  }

  assert {
    condition     = contains(keys(module.virtualnetwork[0].virtual_network_resource_ids), "secondary")
    error_message = "Expected 'secondary' virtual network to be present in output"
  }
}

run "subnet_resource_ids_output" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      primary = {
        name                         = "primary-vnet"
        address_space                = ["192.168.0.0/24"]
        location                     = "westeurope"
        resource_group_name_existing = "primary-rg"
        subnets = {
          subnet1 = {
            name             = "subnet1"
            address_prefixes = ["192.168.0.0/26"]
          }
          subnet2 = {
            name             = "subnet2"
            address_prefixes = ["192.168.0.64/26"]
          }
        }
      }
    }
  }

  assert {
    condition     = contains(keys(output.virtual_network_subnet_resource_ids), "primary")
    error_message = "Expected 'primary' vnet key in virtual_network_subnet_resource_ids output"
  }

  assert {
    condition     = length(keys(output.virtual_network_subnet_resource_ids["primary"])) == 2
    error_message = "Expected 2 subnets under 'primary', got ${length(keys(output.virtual_network_subnet_resource_ids["primary"]))}"
  }

  assert {
    condition     = contains(keys(output.virtual_network_subnet_resource_ids["primary"]), "subnet1") && contains(keys(output.virtual_network_subnet_resource_ids["primary"]), "subnet2")
    error_message = "Expected 'subnet1' and 'subnet2' keys under 'primary' in virtual_network_subnet_resource_ids output"
  }
}
