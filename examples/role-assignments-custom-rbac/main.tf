terraform {
  required_version = "~> 1.12"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.5"
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

data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "random_uuid" "custom_role" {}

# Create a custom RBAC role definition at subscription scope
resource "azapi_resource" "custom_role" {
  name      = random_uuid.custom_role.result
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  body = {
    properties = {
      roleName    = "Custom Vending Reader ${random_string.suffix.result}"
      description = "Custom role for testing role assignment lookup retry mechanism"
      type        = "CustomRole"
      permissions = [
        {
          actions = [
            "Microsoft.Resources/subscriptions/resourceGroups/read",
            "Microsoft.Resources/subscriptions/read"
          ]
          notActions     = []
          dataActions    = []
          notDataActions = []
        }
      ]
      assignableScopes = [
        "/subscriptions/${data.azapi_client_config.current.subscription_id}"
      ]
    }
  }
}

module "sub_vending" {
  source = "../../"

  location                = "swedencentral"
  enable_telemetry        = false
  role_assignment_enabled = true
  role_assignments = {
    custom_role = {
      # Use the custom role name to test the lookup mechanism
      definition                = "Custom Vending Reader ${random_string.suffix.result}"
      relative_scope            = ""
      principal_id              = data.azapi_client_config.current.object_id
      use_random_uuid           = true
      definition_lookup_enabled = true
      definition_retry_enabled  = true
    }
  }
  subscription_id = data.azapi_client_config.current.subscription_id

  depends_on = [azapi_resource.custom_role]
}
