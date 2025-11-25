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

resource "azurerm_resource_group" "hub" {
  location = "uksouth"
  name     = "rg-hub-${random_string.suffix.result}"
}

resource "azurerm_virtual_network" "hub" {
  location            = azurerm_resource_group.hub.location
  name                = "vnet-hub-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
}

locals {
  resource_groups = {
    rg1 = {
      name     = "rg-spoke1-${random_string.suffix.result}"
      location = azurerm_resource_group.hub.location
    }
    rg2 = {
      name     = "rg-spoke2-${random_string.suffix.result}"
      location = azurerm_resource_group.hub.location
    }
  }
  subscription_name = "alz-spoke-sub-vending-${random_string.suffix.result}"
  virtual_networks = {
    vnet1 = {
      name                    = "vnet-spoke1-${random_string.suffix.result}"
      resource_group_key      = "rg1"
      address_space           = ["10.1.0.0/16"]
      hub_network_resource_id = azurerm_virtual_network.hub.id
    }
    vnet2 = {
      name                    = "vnet-spoke2-${random_string.suffix.result}"
      resource_group_key      = "rg2"
      address_space           = ["10.2.0.0/16"]
      hub_network_resource_id = azurerm_virtual_network.hub.id
    }
  }
}

module "sub-vending" {
  source = "../../"

  location = azurerm_resource_group.hub.location
  # resource groups
  resource_group_creation_enabled = true
  resource_groups                 = local.resource_groups
  # role assignment
  role_assignment_enabled = true
  role_assignments = {
    test = {
      principal_id   = data.azurerm_client_config.current.object_id
      definition     = "Storage Blob Data Contributor"
      relative_scope = ""
    }
  }
  # subscription variables
  subscription_alias_enabled                       = true
  subscription_alias_name                          = local.subscription_name
  subscription_billing_scope                       = var.subscription_billing_scope
  subscription_display_name                        = local.subscription_name
  subscription_register_resource_providers_enabled = true
  subscription_tags = {
    created_by = "avm-ptn-alz-sub-vending"
  }
  subscription_workload = "Production"
  # virtual network variables
  virtual_network_enabled = true
  virtual_networks        = local.virtual_networks
}

