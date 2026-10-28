mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  enable_telemetry = false
  location         = "westeurope"
  name             = "rt-layout"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
  routes = {
    private = {
      address_prefix = "10.0.0.0/8"
      name           = "private-network"
      next_hop_type  = "VnetLocal"
    }
    internet = {
      address_prefix = "0.0.0.0/0"
      name           = "internet"
      next_hop_type  = "Internet"
    }
  }
}

run "preserves_route_instances" {
  command = plan

  providers = {
    azapi     = azapi
    terraform = terraform
  }

  assert {
    condition     = toset(keys(module.route)) == toset(["private", "internet"])
    error_message = "Relocating the route source must preserve the existing module label and instance keys."
  }

  assert {
    condition     = module.route["private"].name == "private-network" && module.route["internet"].name == "internet"
    error_message = "Each route instance must retain its authored resource name."
  }

  assert {
    condition     = toset(keys(output.routes)) == toset(["private", "internet"])
    error_message = "Route outputs must preserve the parent map keys."
  }
}

run "preserves_parent_settings_with_separate_routes" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
    tags                          = { pass = "2" }
  }

  assert {
    condition     = try(length(azapi_resource.this.body.properties.routes) == 0, false)
    error_message = "The parent must provide a routes placeholder for AzAPI request-time preservation."
  }

  assert {
    condition     = azapi_resource.this.body.properties.disableBgpRoutePropagation == true && azapi_resource.this.tags == tomap({ pass = "2" })
    error_message = "Parent tag and BGP changes must remain managed while routes are preserved."
  }
}
