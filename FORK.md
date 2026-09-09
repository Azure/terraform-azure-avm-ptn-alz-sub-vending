# Cabinet Office fork

Fork of [Azure/terraform-azure-avm-ptn-alz-sub-vending](https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending).

## Patches

### AVNM route table coexistence

Corp/online spokes join Azure Virtual Network Manager network groups. AVNM `ManagedOnly` routing attaches managed route tables to subnets after Terraform creates them.

In `modules/virtual-network/main.tf`:

- Bump `Azure/avm-res-network-virtualnetwork/azurerm` to **0.22.1**
- Set module-wide `ignore_body_changes.virtual_networks_subnets` to `["properties.routeTable"]` ([AVM TFFR8](https://azure.github.io/Azure-Verified-Modules/spec/TFFR8/))
- Require Terraform **>= 1.11** and AzAPI **>= 2.12**

Remove this fork when upstream sub-vending passes `ignore_body_changes` through and pins a compatible VNet module version.

## Syncing upstream

```bash
git remote add upstream https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending.git
git fetch upstream --tags
git merge upstream/main   # or merge a specific release tag
# Re-apply the AVNM patch if modules/virtual-network/main.tf conflicted
```

## Releases

Tag Cabinet Office releases as `v<upstream>-co.<n>`, for example `v0.3.2-co.1`.

## CI

Upstream AVM end-to-end tests are replaced with `terraform fmt` and `terraform validate` only. This fork is a thin patch layer consumed by `co-azure-tf-modules/azure-subscription`, not a full AVM contribution repo.
