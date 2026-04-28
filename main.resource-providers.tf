module "resourceproviders" {
  source   = "./modules/resource-provider"
  for_each = { for k, v in var.subscription_register_resource_providers_and_features : k => v if var.subscription_register_resource_providers_enabled }

  resource_provider = each.key
  subscription_id   = local.subscription_id
  features          = each.value

  # Note: This module intentionally does not declare a `depends_on` against the
  # other resource modules in this pattern. Forcing resource-provider
  # registration to run after the resources that consume those providers
  # creates a circular ordering problem: a change to
  # `var.subscription_register_resource_providers_and_features` would force
  # those downstream modules to re-plan as well.
  #
  # Instead, the resources that depend on a registered resource provider
  # (virtual networks, budgets, route tables, NSGs, UMIs, etc.) retry on the
  # `MissingSubscriptionRegistration` error returned by ARM, which lets the
  # registration race-with the resource creation safely.
}
