# Landing zone resource provider submodule

## Overview

Registers resource providers and features. Must be performed after all other provisioning is complete.

## Notes

**Breaking change:** direct callers must now supply `location`, including when `enable_telemetry = false`. Choose a region available in your Azure cloud for the telemetry deployment.

See [README.md](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending#readme) in the parent module for more information.

## Example

```terraform
module "resourceproviders" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure//modules/resource-provider"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  location          = "westeurope"
  resource_provider = "Microsoft.PowerBI"
  subscription_id   = "00000000-0000-0000-0000-000000000000"
  features          = ["DailyPrivateLinkServicesForPowerBI"]
}
```
