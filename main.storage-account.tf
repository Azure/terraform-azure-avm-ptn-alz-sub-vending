module "storageaccount" {
  source   = "./modules/storage-account"
  for_each = { for sa_k, sa_v in var.storage_accounts : sa_k => sa_v if var.storage_account_enabled }

  location = coalesce(each.value.location, var.location)
  name     = each.value.name
  resource_group_name = coalesce(
    can(module.resourcegroup[each.value.resource_group_key].resource_group_name) ? module.resourcegroup[each.value.resource_group_key].resource_group_name : null,
    each.value.resource_group_name_existing != null ? each.value.resource_group_name_existing : null
  )

  # Storage account configuration
  access_tier              = each.value.access_tier
  account_kind             = each.value.account_kind
  account_replication_type = each.value.account_replication_type
  account_tier             = each.value.account_tier

  # Security
  cross_tenant_replication_enabled  = each.value.cross_tenant_replication_enabled
  https_traffic_only_enabled        = each.value.https_traffic_only_enabled
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  min_tls_version                   = each.value.min_tls_version
  public_network_access_enabled     = each.value.public_network_access_enabled
  shared_access_key_enabled         = each.value.shared_access_key_enabled

  # Blob
  blob_properties     = each.value.blob_properties
  immutability_policy = each.value.immutability_policy
  containers          = each.value.containers

  # Networking
  network_rules                           = each.value.network_rules
  private_endpoints                       = each.value.private_endpoints
  private_endpoints_manage_dns_zone_group = each.value.private_endpoints_manage_dns_zone_group

  # Identity & RBAC
  managed_identities = each.value.managed_identities
  role_assignments   = each.value.role_assignments

  # Lock
  lock = each.value.lock

  # Diagnostics
  diagnostic_settings_blob            = each.value.diagnostic_settings_blob
  diagnostic_settings_storage_account = each.value.diagnostic_settings_storage_account

  # Misc
  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}
