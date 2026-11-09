mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  enable_telemetry    = false
  location            = "westeurope"
  lock_enabled        = true
  resource_group_name = "rg-test"
  subscription_id     = "00000000-0000-0000-0000-000000000000"
}

run "retry_is_applied_to_resource_group_and_lock" {
  command = plan

  variables {
    retry = {
      error_message_regex = ["MissingSubscriptionRegistration"]
    }
  }

  assert {
    condition     = azapi_resource.rg.retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The resource group must retry on MissingSubscriptionRegistration."
  }

  assert {
    condition     = azapi_resource.rg_lock[0].retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The resource group lock must retry on MissingSubscriptionRegistration."
  }
}

run "retry_is_omitted_when_null" {
  command = plan

  assert {
    condition     = azapi_resource.rg.retry == null && azapi_resource.rg_lock[0].retry == null
    error_message = "No retry must be set when none is supplied."
  }
}
