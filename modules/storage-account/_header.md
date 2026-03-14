# Landing zone storage account submodule

## Overview

Creates a storage account in the specified resource group and subscription, pre-configured for Terraform state file storage.

The storage account is configured with security defaults appropriate for state storage:

- HTTPS-only traffic
- TLS 1.2 minimum
- Public network access disabled by default
- Public blob access always disabled
- Azure AD authentication (shared key access disabled by default)
- Blob versioning and soft-delete enabled by default
- Network rules defaulting to `Deny`

Supports optional configuration of private endpoints, blob containers, role assignments, managed identities, and diagnostics.

## Notes

See [README.md](https://github.com/Azure/terraform-azurerm-lz-vending#readme) in the parent module for more information.

## Example

See documentation for optional parameters.

```terraform
module "storageaccount" {
  source  = "Azure/lz-vending/azurerm/modules/storageaccount"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  location            = "eastus"
  name                = "stmyworkload001"
  resource_group_name = "rg-myworkload"

  containers = {
    tfstate = {
      name = "tfstate"
    }
  }

  private_endpoints = {
    blob = {
      subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking/providers/Microsoft.Network/virtualNetworks/vnet-spoke/subnets/snet-pe"
      subresource_name              = "blob"
      private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
    }
  }
}
```
