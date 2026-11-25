# Landing zone budget submodule

## Overview

Creates a budget in Azure. Designed to be instantiated multiple times to create multiple budgets.

## Notes

**Breaking change:** direct callers must now supply `location`, including when `enable_telemetry = false`. Choose a region available in your Azure cloud for the telemetry deployment.

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

```terraform
module "budget" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/budget"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  location          = "westeurope"
  budget_name       = "budget1"
  budget_amount     = 100
  budget_scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
  budget_time_grain = "Monthly"
  budget_time_period = {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }
}
```
