# Landing zone role assignment submodule

## Overview

Creates a role assignment at subscription or lower scope.
Module is designed to be instantiated many times, once per role assignment.

## Notes

**Breaking change:** direct callers must now supply `location`, including when `enable_telemetry = false`. Choose a region available in your Azure cloud for the telemetry deployment.

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

```terraform
module "roleassignment" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/role-assignment"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  location                     = "westeurope"
  role_assignment_definition   = "Owner"
  role_assignment_scope        = "/subscriptions/00000000-0000-0000-0000-000000000000"
  role_assignment_principal_id = "00000000-0000-0000-0000-000000000000"
}
```
