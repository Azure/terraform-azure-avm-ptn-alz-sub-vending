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
