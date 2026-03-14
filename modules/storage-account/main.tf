# module.storage_account uses the Azure Verified Module to create the storage account
# and its child resources (blob service, containers, private endpoints).
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name

  # Storage account configuration
  access_tier              = var.access_tier
  account_kind             = var.account_kind
  account_replication_type = var.account_replication_type
  account_tier             = var.account_tier

  # Security hardening - public blob access always disabled for state storage
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled

  # Blob properties (versioning, soft-delete, change feed)
  blob_properties = var.blob_properties

  # Account-level immutability policy
  immutability_policy = var.immutability_policy

  # Containers
  containers = var.containers

  # Networking
  network_rules = var.network_rules

  # Private endpoints
  private_endpoints                       = var.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group

  # Identity
  managed_identities = var.managed_identities

  # RBAC
  role_assignments = var.role_assignments

  # Diagnostics
  diagnostic_settings_blob            = var.diagnostic_settings_blob
  diagnostic_settings_storage_account = var.diagnostic_settings_storage_account

  # Lock
  lock = var.lock

  # Telemetry
  enable_telemetry = var.enable_telemetry

  tags = var.tags
}
