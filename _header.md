## Overview

The landing zone Terraform module is designed to accelerate deployment of individual landing zones within an Azure tenant.
We use the [AzAPI](https://registry.terraform.io/providers/azure/azapi/latest) provider to create the subscription and deploy the resources in a single `terraform apply` step.

The module is designed to be instantiated many times, once for each desired landing zone.

This is currently split logically into the following capabilities:

- Subscription creation and management group placement
- Networking - deploy multiple vnets with:
  - Hub & spoke connectivity (peering to a hub network)
  - vWAN connectivity
  - Mesh peering (peering between spokes)
  - IPAM pool allocation (dynamic address space from Azure Virtual Network Manager IPAM)
- Role assignments
- Resource provider (and feature) registration
- Resource group creation
- User assigned managed identity creation
  - Federated credential configuration for GitHub Actions, Terraform Cloud, and other providers.

> When creating virtual network peerings, be aware of the [limit of peerings per virtual network](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-subscription-service-limits?toc=%2Fazure%2Fvirtual-network%2Ftoc.json#azure-resource-manager-virtual-networking-limits).

We would like feedback on what's missing in the module.
Please raise an [issue](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending/issues) if you have any suggestions.

## Breaking changes

### Submodule source migration

The security-rule and route implementations are now direct children of `modules/`. Direct consumers must update their Registry source suffixes when selecting a version containing this change:

| Previous source suffix | New source suffix |
| --- | --- |
| `//modules/network-security-group/modules/security-rule` | `//modules/network-security-group-security-rule` |
| `//modules/route-table/modules/route` | `//modules/route-table-route` |

Use `Azure/avm-ptn-alz-sub-vending/azure` before either suffix. Root module consumers do not need to change their source. Retain existing module block names and instance keys; this source relocation does not change the module or resource labels used in Terraform state addresses.

### Required location for direct submodule callers

Direct callers of the following previously location-free submodules must now supply a non-null `location` string:

- `//modules/budget`
- `//modules/resource-provider`
- `//modules/role-assignment`
- `//modules/subscription`
- `//modules/network-security-group-security-rule`
- `//modules/route-table-route`

Pass a region available in your Azure cloud, for example `location = "westeurope"`. This input is required even when `enable_telemetry = false`; disabling telemetry does not remove Terraform's required-argument contract. With telemetry enabled, the region is used for the subscription-scoped telemetry deployment, including for global or scope-based business resources. Root module callers already supply `location`, which is forwarded to these children.

## Example

The below example created a landing zone subscription with two virtual networks.
One virtual network is in the default location of the subscription, the other is in a different location.

The virtual networks are peered with the supplied hub network resource ids, they are also peered with each other using the mesh peering option.

```terraform
module "lz_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  # Set the default location for resources
  location = "westeurope"

  # subscription variables
  subscription_alias_enabled = true
  subscription_billing_scope = "/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
  subscription_display_name  = "my-subscription-display-name"
  subscription_alias_name    = "my-subscription-alias"
  subscription_workload      = "Production"

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = "Corp"

  # virtual network variables
  virtual_network_enabled = true
  virtual_networks = {
    one = {
      name                    = "my-vnet"
      address_space           = ["192.168.1.0/24"]
      hub_peering_enabled     = true
      hub_network_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-hub-network-rg/providers/Microsoft.Network/virtualNetworks/my-hub-network"
      mesh_peering_enabled    = true
    }
    two = {
      name                    = "my-vnet2"
      location                = "northeurope"
      address_space           = ["192.168.2.0/24"]
      hub_peering_enabled     = true
      hub_network_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-hub-network-rg/providers/Microsoft.Network/virtualNetworks/my-hub-network2"
      mesh_peering_enabled    = true
    }
  }

  umi_enabled             = true
  umi_name                = "umi"
  umi_resource_group_name = "rg-identity"
  umi_role_assignments = {
    myrg-contrib = {
      definition     = "Contributor"
      relative_scope = "/resourceGroups/MyRg"
    }
  }

  resource_group_creation_enabled = true
  resource_groups = {
    nwrg = {
      name     = "NetworkWatcherRG"
      location = "westeurope"
    }
    myrg = {
      name     = "MyRg"
      location = "westeurope"
    }
  }

  # role assignments
  role_assignment_enabled = true
  role_assignments = {
    # using role definition name, created at subscription scope
    contrib_user_sub = {
      principal_id   = "00000000-0000-0000-0000-000000000000"
      definition     = "Contributor"
      relative_scope = ""
    },
    # using a custom role definition
    custdef_sub_scope = {
      principal_id   = "11111111-1111-1111-1111-111111111111"
      definition     = "/providers/Microsoft.Management/MyMg/providers/Microsoft.Authorization/roleDefinitions/ffffffff-ffff-ffff-ffff-ffffffffffff"
      relative_scope = ""
    },
    # using relative scope (to the created or supplied subscription)
    rg_owner = {
      principal_id   = "00000000-0000-0000-0000-000000000000"
      definition     = "Owner"
      relative_scope = "/resourceGroups/MyRg"
    },
  }
}
```

## IPAM Pool Allocation

Instead of specifying static CIDR ranges, you can allocate address space dynamically from Azure Virtual Network Manager IPAM pools.
This eliminates manual IP address planning and prevents overlapping address spaces across landing zones.

Use `ipam_pools` instead of `address_space` at the VNet level, and instead of `address_prefixes` at the subnet level.
These are mutually exclusive — you must use one or the other for each VNet and each subnet.

```terraform
module "lz_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "<version>"

  location = "westeurope"

  subscription_alias_enabled = true
  subscription_billing_scope = "/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
  subscription_display_name  = "my-ipam-subscription"
  subscription_alias_name    = "my-ipam-subscription"
  subscription_workload      = "Production"

  virtual_network_enabled = true
  virtual_networks = {
    spoke = {
      name               = "vnet-spoke"
      resource_group_key = "rg1"
      # Dynamic address space from IPAM pool
      ipam_pools = [{
        id            = "/subscriptions/.../providers/Microsoft.Network/networkManagers/my-nm/ipamPools/my-pool"
        prefix_length = 24
      }]
      subnets = {
        workload = {
          name = "subnet-workload"
          ipam_pools = [{
            pool_id       = "/subscriptions/.../providers/Microsoft.Network/networkManagers/my-nm/ipamPools/my-pool"
            prefix_length = 26
          }]
        }
      }
    }
  }
}
```