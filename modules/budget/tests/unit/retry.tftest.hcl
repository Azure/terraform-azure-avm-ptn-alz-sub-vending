mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  budget_amount     = 1000
  budget_name       = "budget"
  budget_scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
  budget_time_grain = "Monthly"
  budget_time_period = {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }
  enable_telemetry = false
  location         = "westeurope"
}

run "retry_is_applied_to_budget" {
  command = plan

  variables {
    retry = {
      error_message_regex = ["MissingSubscriptionRegistration"]
    }
  }

  assert {
    condition     = azapi_resource.budget.retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The budget must retry on MissingSubscriptionRegistration."
  }
}

run "retry_is_omitted_when_null" {
  command = plan

  assert {
    condition     = azapi_resource.budget.retry == null
    error_message = "The budget must not set a retry when none is supplied."
  }
}
