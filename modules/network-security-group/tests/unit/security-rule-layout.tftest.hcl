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
  name             = "nsg-layout"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
  security_rules = {
    https = {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "allow-https"
      priority                   = 100
      protocol                   = "Tcp"
      destination_address_prefix = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    ssh = {
      access                     = "Deny"
      direction                  = "Inbound"
      name                       = "deny-ssh"
      priority                   = 200
      protocol                   = "Tcp"
      destination_address_prefix = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}

run "preserves_security_rule_instances" {
  command = plan

  providers = {
    azapi     = azapi
    terraform = terraform
  }

  assert {
    condition     = toset(keys(module.security_rule)) == toset(["https", "ssh"])
    error_message = "Relocating the security-rule source must preserve the existing module label and instance keys."
  }

  assert {
    condition     = module.security_rule["https"].name == "allow-https" && module.security_rule["ssh"].name == "deny-ssh"
    error_message = "Each security-rule instance must retain its authored resource name."
  }

  assert {
    condition     = toset(keys(output.security_rules)) == toset(["https", "ssh"])
    error_message = "Security-rule outputs must preserve the parent map keys."
  }
}

run "preserves_parent_settings_with_separate_rules" {
  command = plan

  variables {
    tags = { pass = "2" }
  }

  assert {
    condition     = try(length(azapi_resource.this.body.properties.securityRules) == 0, false)
    error_message = "The parent must provide a securityRules placeholder for AzAPI request-time preservation."
  }

  assert {
    condition     = azapi_resource.this.tags == tomap({ pass = "2" })
    error_message = "Parent tag changes must remain managed while separate security rules are preserved."
  }

  assert {
    condition     = var.ignore_body_changes.this == tolist(["properties.securityRules"])
    error_message = "By default, parent updates must preserve the live security rules collection."
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
    condition     = var.ignore_body_changes.this == tolist(["properties.securityRules"])
    error_message = "A null path list from the root module must keep the default security rules protection."
  }
}

run "consumer_overrides_parent_ignore_body_changes" {
  command = plan

  variables {
    ignore_body_changes = {
      this = ["properties.securityRules", "tags"]
    }
  }

  assert {
    condition     = var.ignore_body_changes.this == tolist(["properties.securityRules", "tags"])
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
