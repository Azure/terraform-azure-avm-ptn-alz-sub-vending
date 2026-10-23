# Landing zone subscription submodule

## Overview

Creates a subscription alias, and optionally manages management group association for the resulting subscription.

## Notes

**Breaking change:** direct callers must now supply `location`, including when `enable_telemetry = false`. Choose a region available in your Azure cloud for the telemetry deployment.

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

```terraform
module "subscription" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/subscription"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  location                                          = "westeurope"
  subscription_alias_enabled                        = true
  subscription_billing_scope                        = "/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
  subscription_display_name                         = "my-subscription-display-name"
  subscription_alias_name                           = "my-subscription-alias"
  subscription_workload                             = "Production"
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = "mymg"
}
```
