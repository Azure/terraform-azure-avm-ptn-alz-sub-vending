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
  enable_telemetry           = false
  location                   = "westeurope"
  name                       = "allow-https"
  parent_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Network/networkSecurityGroups/example"
  priority                   = 100
  protocol                   = "Tcp"
  destination_address_prefix = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  source_port_range          = "*"
}

run "supports_direct_security_rule_consumption" {
  command = plan

  providers = {
    azapi     = azapi
    terraform = terraform
  }

  assert {
    condition     = azapi_resource.this.parent_id == var.parent_id && output.name == var.name
    error_message = "The direct security-rule module must retain its parent and resource identity."
  }

  assert {
    condition     = azapi_resource.this.body.properties.destinationPortRange == "443" && azapi_resource.this.body.properties.priority == 100
    error_message = "The direct security-rule module must retain its authored rule properties."
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "Disabling telemetry must not create telemetry resources."
  }
}
