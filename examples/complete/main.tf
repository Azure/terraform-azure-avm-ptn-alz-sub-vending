terraform {
  required_version = "~> 1.8"

  required_providers {
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

module "sub_vending" {
  source = "../../"

  location                        = "westeurope"
  disable_telemetry               = true
  resource_group_creation_enabled = true
  resource_groups = {
    rg1 = {
      name     = "rg-${random_string.suffix.result}"
      location = "westeurope"
    }
  }
  role_assignments = {
    rg1 = {
      definition     = "Storage Blob Data Contributor"
      relative_scope = "/resourceGroups/rg-${random_string.suffix.result}"
      principal_id   = data.azurerm_client_config.current.object_id
    }
  }
  subscription_id                                  = data.azurerm_client_config.current.subscription_id
  subscription_register_resource_providers_enabled = true
  umi_enabled                                      = true
  user_managed_identities = {
    "default" = {
      name               = "umi-${random_string.suffix.result}"
      resource_group_key = "rg1"
      role_assignments = {
        "blob" = {
          definition     = "Storage Blob Data Contributor"
          relative_scope = "/resourceGroups/rg-${random_string.suffix.result}"
        }
      }
    }
  }
}

module "sub_vending_rg_existing" {
  source = "../../"

  location                                         = "westeurope"
  disable_telemetry                                = true
  resource_group_creation_enabled                  = false
  subscription_id                                  = data.azurerm_client_config.current.subscription_id
  subscription_register_resource_providers_enabled = true
  umi_enabled                                      = true
  user_managed_identities = {
    "default" = {
      name                         = "umi-0${random_string.suffix.result}"
      resource_group_name_existing = "rg-${random_string.suffix.result}"
      role_assignments = {
        "blob" = {
          definition     = "Storage Blob Data Contributor"
          relative_scope = "/resourceGroups/rg-${random_string.suffix.result}"
        }
      }
    }
  }

  depends_on = [module.sub_vending]
}
