terraform {
  required_version = "~> 1.8"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "azurerm_resource_group" "ipam" {
  location = "uksouth"
  name     = "rg-ipam-${random_string.suffix.result}"
}

# Create a Network Manager for IPAM
# In production, scope this to a management group covering all landing zone subscriptions.
# For this example we scope to the current subscription to avoid chicken-and-egg issues
# with newly vended subscriptions not yet being in the NM scope.
resource "azapi_resource" "network_manager" {
  location  = azurerm_resource_group.ipam.location
  name      = "nm-ipam-${random_string.suffix.result}"
  parent_id = azurerm_resource_group.ipam.id
  type      = "Microsoft.Network/networkManagers@2024-07-01"
  body = {
    properties = {
      networkManagerScopeAccesses = []
      networkManagerScopes = {
        subscriptions = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
      }
    }
  }
  retry = {
    interval_seconds     = 10
    max_interval_seconds = 180
    error_message_regex  = ["CannotDeleteResource", "Cannot delete resource while nested resources exist"]
  }
  schema_validation_enabled = false
}

# Create an IPAM pool
resource "azapi_resource" "ipam_pool" {
  location  = azurerm_resource_group.ipam.location
  name      = "pool-10-0-0-0-8"
  parent_id = azapi_resource.network_manager.id
  type      = "Microsoft.Network/networkManagers/ipamPools@2024-07-01"
  body = {
    properties = {
      addressPrefixes = ["10.0.0.0/8"]
    }
  }
  retry = {
    interval_seconds     = 10
    max_interval_seconds = 180
    error_message_regex  = ["BadRequest", "Ipam pool.*has Azure resources associated"]
  }
  schema_validation_enabled = false

  depends_on = [azapi_resource.network_manager]
}

locals {
  virtual_networks = {
    vnet1 = {
      name                         = "vnet-spoke-ipam-${random_string.suffix.result}"
      resource_group_name_existing = azurerm_resource_group.ipam.name
      # Use IPAM pool instead of static address_space
      ipam_pools = [{
        id            = azapi_resource.ipam_pool.id
        prefix_length = 24
      }]
      subnets = {
        subnet1 = {
          name = "subnet-workload"
          ipam_pools = [{
            pool_id       = azapi_resource.ipam_pool.id
            prefix_length = 26
          }]
        }
        subnet2 = {
          name = "subnet-endpoints"
          ipam_pools = [{
            pool_id       = azapi_resource.ipam_pool.id
            prefix_length = 27
          }]
        }
      }
    }
  }
}

# This example uses an existing subscription to demonstrate IPAM pool allocation.
# The Network Manager must have scope over the subscription where VNets are created.
# When vending new subscriptions, use a management group-scoped Network Manager instead.
module "sub_vending" {
  source = "../../"

  location = azurerm_resource_group.ipam.location
  # Use the current subscription (NM is scoped here)
  subscription_id = data.azurerm_client_config.current.subscription_id
  # virtual network variables with IPAM
  virtual_network_enabled = true
  virtual_networks        = local.virtual_networks
}
