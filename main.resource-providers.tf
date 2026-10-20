module "resourceproviders" {
  source   = "./modules/resource-provider"
  for_each = { for k, v in var.subscription_register_resource_providers_and_features : k => v if var.subscription_register_resource_providers_enabled }

  location          = var.location
  resource_provider = each.key
  subscription_id   = local.subscription_id
  enable_telemetry  = var.enable_telemetry
  features          = each.value

  depends_on = [
    module.resourcegroup,
    module.roleassignment,
    module.roleassignment_umi,
    module.subscription,
    module.usermanagedidentity,
    module.virtualnetwork,
  ]
}
