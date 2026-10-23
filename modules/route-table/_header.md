# Landing zone route table submodule

## Overview

Creates multiple route tables in the supplied subscription.
Optionally:

- Creates routes within the route tables

## Notes

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

See documentation for optional parameters.

```terraform
module "routetable" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/route-table"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  name      = "myroutetable"
  location  = var.location
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
  routes = {
    rt1 = {
      name                   = "private-network"
      address_prefix         = "192.168.0.0/24"
      next_hop_in_ip_address = "192.168.0.5"
      next_hop_type          = "VirtualAppliance"
    },
    rt2 = {
      name           = "internet"
      address_prefix = "GatewayManager"
      next_hop_type  = "Internet"
    }
  }
}
```
