# Landing zone network security group submodule

## Overview

Creates multiple network security groups in the supplied subscription.
Optionally:

- Creates security rules within the network security groups.

## Notes

Terraform 1.11 or later, below 2.0, is required. Parent updates use AzAPI's write-only `ignore_body_changes` argument to read and preserve the live security-rules collection, including rules managed outside this module. The empty collection in the parent body is a placeholder, not a declaration of rule ownership. Tags remain managed normally.

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

See documentation for optional parameters.

```terraform
module "networksecuritygroup" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/network-security-group"
  version = "<version>"

  name      = "test-nsg1"
  location  = var.location
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"

  security_rules = {
    "rule01" = {
      name                       = "test-r1"
      access                     = "Deny"
      destination_address_prefix = "*"
      destination_port_range     = "80-88"
      direction                  = "Outbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "rule02" = {
      name                       = "test-r2"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}
```
