# route submodule

This submodule deploys a route as a child resource of a route table.

**Breaking changes:** the source suffix is now `//modules/route-table-route` instead of `//modules/route-table/modules/route`. Direct callers must also supply `location`, including when `enable_telemetry = false`; choose a region available in your Azure cloud for the telemetry deployment.

## Usage

The `route-table` module calls this submodule using `for_each`. It can also be consumed directly:

```terraform
module "route" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/route-table-route"
  version = "<version>"

  address_prefix = "10.0.0.0/8"
  location       = var.location
  name           = "private-network"
  next_hop_type  = "VnetLocal"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Network/routeTables/example"
}
```
