module "resourceproviders" {
  source   = "./modules/resource-provider"
  for_each = { for k, v in var.subscription_register_resource_providers_and_features : k => v if var.subscription_register_resource_providers_enabled }

  resource_provider = each.key
  subscription_id   = local.subscription_id
  features          = each.value

  # Note: this module declares an explicit `depends_on` against the other
  # resource modules in this pattern. Resource-provider registration runs last,
  # ensuring that any RPs the other modules need are registered on demand by
  # the underlying `azapi` provider during their own resource creation, while
  # this module is responsible for registering the full configured set
  # (including RPs that no resource in this run consumes) at the end.
  depends_on = [
    module.resourcegroup,
    module.roleassignment,
    module.roleassignment_umi,
    module.subscription,
    module.usermanagedidentity,
    module.virtualnetwork,
  ]
}
