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

  assert {
    condition     = var.ignore_body_changes.this == tolist(["properties.routes"])
    error_message = "By default, parent updates must preserve the live routes collection."
  }
}

run "root_omitted_override_keeps_default" {
  command = plan

  variables {
    ignore_body_changes = {
      this = null
    }
  }

  assert {
    condition     = var.ignore_body_changes.this == tolist(["properties.routes"])
    error_message = "A null path list from the root module must keep the default routes protection."
  }
}

run "consumer_overrides_parent_ignore_body_changes" {
  command = plan

  variables {
    ignore_body_changes = {
      this = ["properties.routes", "tags"]
    }
  }

  assert {
    condition     = var.ignore_body_changes.this == tolist(["properties.routes", "tags"])
    error_message = "Consumers must be able to replace the parent ignore_body_changes paths."
  }
}

run "consumer_can_clear_parent_ignore_body_changes" {
  command = plan

  variables {
    ignore_body_changes = {
      this = []
    }
  }

  assert {
    condition     = length(var.ignore_body_changes.this) == 0
    error_message = "Consumers must be able to remove the default parent ignore_body_changes paths."
  }
}
