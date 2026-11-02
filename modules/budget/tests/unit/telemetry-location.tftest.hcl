mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  budget_amount     = 100
  budget_name       = "example"
  budget_scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
  budget_time_grain = "Monthly"
  budget_time_period = {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }
}

run "omitting_location_with_telemetry_disabled_keeps_budget" {
  command = plan

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = azapi_resource.budget.body.properties.amount == 100 && length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "A budget must plan without a location or telemetry deployment when telemetry is disabled."
  }
}

run "null_location_with_telemetry_disabled" {
  command = plan

  variables {
    enable_telemetry = false
    location         = null
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 0
    error_message = "An explicit null location must be accepted when telemetry is disabled."
  }
}

run "omitting_location_with_default_telemetry_is_rejected" {
  command = plan

  expect_failures = [var.location]
}

run "null_location_with_telemetry_enabled_is_rejected" {
  command = plan

  variables {
    enable_telemetry = true
    location         = null
  }

  expect_failures = [var.location]
}

run "supplied_location_keeps_telemetry_enabled" {
  command = plan

  variables {
    enable_telemetry = true
    location         = "westeurope"
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 1 && azapi_resource.telemetry[0].location == "westeurope" && azapi_resource.budget.body.properties.amount == 100
    error_message = "Supplying a location must retain telemetry in that region and the configured budget."
  }
}
