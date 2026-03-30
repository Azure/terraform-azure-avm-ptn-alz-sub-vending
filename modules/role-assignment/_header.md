# Landing zone role assignment submodule

## Overview

Creates a role assignment at subscription or lower scope.
Module is designed to be instantiated many times, once per role assignment.

## Notes

See [README.md](https://github.com/Azure/terraform-azurerm-lz-vending#readme) in the parent module for more information.

## Role Definition Lookup Retry Mechanism

When using role definition names (e.g., `Contributor`) instead of resource IDs, the module performs a lookup to resolve the name to a resource ID. In some scenarios, such as when a subscription is newly placed under a management group with custom RBAC role definitions, there can be a race condition where the role definition is not immediately visible.

To handle this, the module implements an automatic retry mechanism:

1. **First lookup**: The module attempts to resolve the role definition name immediately
2. **Retry on failure**: If the first lookup fails (`role_definition_id` is `null`) and `role_assignment_definition_lookup_enabled` is `true`:
   - A 30-second delay is introduced via `time_sleep`
   - A second lookup is performed
3. **Final resolution**: The module uses the first successful lookup result

### Behavior on Subsequent Runs

On subsequent Terraform runs, if the role definition is now visible:

- The first lookup will succeed
- The retry resources (`time_sleep` and the retry lookup module) will be destroyed automatically
- No 30-second delay will occur

This ensures optimal performance on steady-state runs while handling the initial race condition gracefully.

## Example

```terraform
module "roleassignment" {
  source          = "Azure/lz-vending/azurerm/modules/roleassignment"
  version         = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
  role_definition = "Owner"
  scope           = "/subscriptions/00000000-0000-0000-0000-000000000000"
  principal_id    = "00000000-0000-0000-0000-000000000000"
}
```
