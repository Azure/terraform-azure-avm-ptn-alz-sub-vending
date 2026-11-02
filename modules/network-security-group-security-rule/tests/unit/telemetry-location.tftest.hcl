mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  access                     = "Allow"
  direction                  = "Inbound"
  name                       = "allow-https"
  parent_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Network/networkSecurityGroups/example"
  priority                   = 100
  protocol                   = "Tcp"
  destination_address_prefix = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  source_port_range          = "*"
}

run "omitting_location_with_telemetry_disabled_keeps_security_rule" {
  command = plan

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = azapi_resource.this.body.properties.destinationPortRange == "443" && length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "A security rule must plan without a location or telemetry deployment when telemetry is disabled."
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
    condition     = length(azapi_resource.telemetry) == 1 && azapi_resource.telemetry[0].location == "westeurope" && azapi_resource.this.body.properties.destinationPortRange == "443"
    error_message = "Supplying a location must retain telemetry in that region and the configured security rule."
  }
}
