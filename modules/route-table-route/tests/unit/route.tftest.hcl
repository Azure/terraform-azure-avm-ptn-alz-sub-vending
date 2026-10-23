mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  address_prefix   = "10.0.0.0/8"
  enable_telemetry = false
  location         = "westeurope"
  name             = "private-network"
  next_hop_type    = "VnetLocal"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Network/routeTables/example"
}

run "supports_direct_route_consumption" {
  command = plan

  providers = {
    azapi     = azapi
    terraform = terraform
  }

  assert {
    condition     = azapi_resource.this.parent_id == var.parent_id && output.name == var.name
    error_message = "The direct route module must retain its parent and resource identity."
  }

  assert {
    condition     = azapi_resource.this.body.properties.addressPrefix == "10.0.0.0/8" && azapi_resource.this.body.properties.nextHopType == "VnetLocal"
    error_message = "The direct route module must retain its authored routing properties."
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "Disabling telemetry must not create telemetry resources."
  }
}
