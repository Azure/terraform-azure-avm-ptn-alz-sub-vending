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

run "vnet_with_subnet_address_prefix" {
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
          singular = {
            name           = "snet-singular"
            address_prefix = "192.168.0.0/26"
          }
          plural = {
            name             = "snet-plural"
            address_prefixes = ["192.168.0.64/26"]
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
    condition     = var.virtual_networks["primary"].subnets["singular"].address_prefix == "192.168.0.0/26"
    error_message = "Expected the singular subnet to use address_prefix"
  }

  assert {
    condition     = var.virtual_networks["primary"].subnets["singular"].address_prefixes == null
    error_message = "Expected the singular subnet to have null address_prefixes"
  }
}
