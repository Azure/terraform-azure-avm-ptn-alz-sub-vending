# security-rule submodule

This submodule deploys a network security rule as a child resource of a network security group.

**Breaking changes:** the source suffix is now `//modules/network-security-group-security-rule` instead of `//modules/network-security-group/modules/security-rule`. Direct callers must also supply `location`, including when `enable_telemetry = false`; choose a region available in your Azure cloud for the telemetry deployment.

## Usage

The `network-security-group` module calls this submodule using `for_each`. It can also be consumed directly:

```terraform
module "security_rule" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/network-security-group-security-rule"
  version = "<version>"

  access                     = "Allow"
  direction                  = "Inbound"
  location                   = var.location
  name                       = "allow-https"
  parent_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Network/networkSecurityGroups/example"
  priority                   = 100
  protocol                   = "Tcp"
  destination_address_prefix = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  source_port_range          = "*"
}
```
