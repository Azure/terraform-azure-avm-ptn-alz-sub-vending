mock_provider "azapi" {
  override_data {
    target = module.role_definitions.data.azapi_resource_list.role_definitions
    values = {
      output = {
        value = []
      }
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "terraform" {}

variables {
  role_assignment_definition   = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
  role_assignment_principal_id = "00000000-0000-0000-0000-000000000000"
  role_assignment_scope        = "/subscriptions/00000000-0000-0000-0000-000000000000"
}

run "omitting_location_with_telemetry_disabled_keeps_role_assignment" {
  command = plan

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = azapi_resource.this.body.properties.principalId == "00000000-0000-0000-0000-000000000000" && length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "A role assignment must plan without a location or telemetry deployment when telemetry is disabled."
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
    condition     = length(azapi_resource.telemetry) == 1 && azapi_resource.telemetry[0].location == "westeurope" && azapi_resource.this.body.properties.principalId == "00000000-0000-0000-0000-000000000000"
    error_message = "Supplying a location must retain telemetry in that region and the configured role assignment."
  }
}
