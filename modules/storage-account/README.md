<!-- BEGIN_TF_DOCS -->

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

<!-- markdownlint-disable MD033 -->

## Requirements

The following requirements are needed by this module:

- [terraform](https://developer.hashicorp.com/terraform/language) (~> 1.10)
- [azapi](https://registry.terraform.io/providers/Azure/azapi/latest) (~> 2.5)
- [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) (~> 4.0)

## Resources

The following resources are used by this module:

- module `storage_account` from `Azure/avm-res-storage-storageaccount/azurerm` (`0.6.7`)

## Required Inputs

The following input variables are required:

- `location`: The Azure region to deploy the storage account into.
- `name`: The name of the storage account.
- `resource_group_name`: The name of the resource group to deploy the storage account into.

## Optional Inputs

This module exposes optional AVM storage-account inputs for:

- account configuration (`access_tier`, `account_kind`, `account_replication_type`, `account_tier`)
- security (`https_traffic_only_enabled`, `min_tls_version`, `public_network_access_enabled`, `shared_access_key_enabled`, `infrastructure_encryption_enabled`, `cross_tenant_replication_enabled`)
- blob settings (`blob_properties`, `immutability_policy`, `containers`)
- networking (`network_rules`, `private_endpoints`, `private_endpoints_manage_dns_zone_group`)
- identity and access (`managed_identities`, `role_assignments`)
- observability (`diagnostic_settings_blob`, `diagnostic_settings_storage_account`)
- governance and metadata (`lock`, `tags`, `enable_telemetry`)

For exact schemas and defaults, see [variables.tf](variables.tf).

## Outputs

The following outputs are exported:

- `resource_id`: The resource ID of the storage account.
- `name`: The name of the storage account.
- `private_endpoints`: A map of private endpoints created on the storage account.
- `containers`: A map of storage containers that are created.

## Modules

- `storage_account`: [Azure/avm-res-storage-storageaccount/azurerm](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest)

<!-- markdownlint-disable-next-line MD041 -->

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

<!-- END_TF_DOCS -->
