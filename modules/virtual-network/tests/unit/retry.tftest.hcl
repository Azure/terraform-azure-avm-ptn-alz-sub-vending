mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "modtm" {}

mock_provider "terraform" {}

variables {
  enable_telemetry = false
  location         = "uksouth"
  subscription_id  = "00000000-0000-0000-0000-000000000000"
  virtual_networks = {
    standard = {
      name                         = "vnet-standard"
      address_space                = ["192.168.0.0/24"]
      resource_group_name_existing = "rg-existing"
      resource_group_name          = "rg-existing"
      vwan_connection_enabled      = true
      vwan_hub_resource_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualHubs/vhub"
    }
    routing_intent = {
      name                         = "vnet-intent"
      address_space                = ["192.168.1.0/24"]
      resource_group_name_existing = "rg-existing"
      resource_group_name          = "rg-existing"
      vwan_connection_enabled      = true
      vwan_hub_resource_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualHubs/vhub"
      vwan_security_configuration = {
        routing_intent_enabled = true
      }
    }
  }
}

run "retry_is_applied_to_vwan_connections" {
  command = plan

  variables {
    retry = {
      error_message_regex = ["MissingSubscriptionRegistration"]
    }
  }

  assert {
    condition     = azapi_resource.vhubconnection["standard"].retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The vWAN hub connection must retry on MissingSubscriptionRegistration."
  }

  assert {
    condition     = azapi_resource.vhubconnection_routing_intent["routing_intent"].retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The routing intent vWAN hub connection must retry on MissingSubscriptionRegistration."
  }

  assert {
    condition     = contains(local.upstream_retry.error_message_regex, "ReferencedResourceNotProvisioned") && contains(local.upstream_retry.error_message_regex, "MissingSubscriptionRegistration")
    error_message = "The AVM virtual network module must keep its own default pattern next to the supplied ones."
  }
}

run "upstream_defaults_are_kept_without_retry" {
  command = plan

  assert {
    condition     = local.upstream_retry.error_message_regex == tolist(["ReferencedResourceNotProvisioned"]) && local.upstream_retry.interval_seconds == 10 && local.upstream_retry.max_interval_seconds == 180
    error_message = "Without a retry input the AVM virtual network module must keep its own defaults."
  }
}
