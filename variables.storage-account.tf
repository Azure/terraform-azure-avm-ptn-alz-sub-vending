variable "storage_account_enabled" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Whether to enable the creation of storage accounts.

Requires at least one entry in `var.storage_accounts`.
DESCRIPTION
  nullable    = false
}

variable "storage_accounts" {
  type = map(object({
    name                         = string
    resource_group_key           = optional(string)
    resource_group_name_existing = optional(string)
    location                     = optional(string)
    tags                         = optional(map(string), {})

    # Storage account configuration
    access_tier              = optional(string, "Hot")
    account_kind             = optional(string, "StorageV2")
    account_replication_type = optional(string, "ZRS")
    account_tier             = optional(string, "Standard")

    # Security
    cross_tenant_replication_enabled  = optional(bool, false)
    https_traffic_only_enabled        = optional(bool, true)
    infrastructure_encryption_enabled = optional(bool, false)
    min_tls_version                   = optional(string, "TLS1_2")
    public_network_access_enabled     = optional(bool, false)
    shared_access_key_enabled         = optional(bool, false)

    # Blob properties
    blob_properties = optional(object({
      change_feed_enabled           = optional(bool, false)
      change_feed_retention_in_days = optional(number)
      default_service_version       = optional(string)
      last_access_time_enabled      = optional(bool, false)
      versioning_enabled            = optional(bool, true)
      container_delete_retention_policy = optional(object({
        days    = optional(number, 7)
        enabled = optional(bool, true)
      }), {})
      cors_rule = optional(list(object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })))
      delete_retention_policy = optional(object({
        days                     = optional(number, 7)
        enabled                  = optional(bool, true)
        permanent_delete_enabled = optional(bool, false)
      }), {})
      restore_policy = optional(object({
        days = number
      }))
    }), {})

    # Account-level immutability
    immutability_policy = optional(object({
      allow_protected_append_writes = bool
      period_since_creation_in_days = number
      state                         = string
    }))

    # Containers
    containers = optional(map(object({
      name                           = string
      default_encryption_scope       = optional(string)
      deny_encryption_scope_override = optional(bool)
      metadata                       = optional(map(string))
      public_access                  = optional(string, "None")
      immutable_storage_with_versioning = optional(object({
        enabled = bool
      }))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        description                            = optional(string, null)
        principal_type                         = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
      })), {})
    })), {})

    # Network rules
    network_rules = optional(object({
      bypass                     = optional(set(string), ["AzureServices"])
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(set(string), [])
      virtual_network_subnet_ids = optional(set(string), [])
    }), {})

    # Private endpoints
    private_endpoints = optional(map(object({
      subnet_resource_id                      = string
      subresource_name                        = string
      name                                    = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      network_interface_name                  = optional(string, null)
      private_service_connection_name         = optional(string, null)
      application_security_group_associations = optional(map(string), {})
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        description                            = optional(string, null)
        principal_type                         = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
      })), {})
      tags = optional(map(string), null)
    })), {})
    private_endpoints_manage_dns_zone_group = optional(bool, false)

    # Managed identity
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})

    # RBAC on the storage account itself
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      description                            = optional(string, null)
      principal_type                         = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
    })), {})

    # Lock
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    # Diagnostics
    diagnostic_settings_blob = optional(map(object({
      name                                     = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      log_analytics_destination_type           = optional(string, "Dedicated")
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      marketplace_partner_resource_id          = optional(string, null)
      metric_categories                        = optional(set(string), ["AllMetrics"])
      storage_account_resource_id              = optional(string, null)
      workspace_resource_id                    = optional(string, null)
    })), {})

    diagnostic_settings_storage_account = optional(map(object({
      name                                     = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      log_analytics_destination_type           = optional(string, "Dedicated")
      marketplace_partner_resource_id          = optional(string, null)
      metric_categories                        = optional(set(string), ["AllMetrics"])
      storage_account_resource_id              = optional(string, null)
      workspace_resource_id                    = optional(string, null)
    })), {})

    # Telemetry
    enable_telemetry = optional(bool, true)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of storage accounts to create. The map key must be known at the plan stage. The primary use case is Terraform state file storage for application workloads.

### Required fields

- `name`: The name of the storage account. Must be globally unique, 3–24 lowercase alphanumeric characters. [required]
- `resource_group_key`: The key from `var.resource_groups` to deploy the storage account into. [optional]
- `resource_group_name_existing`: The name of an existing resource group to deploy the storage account into. [optional]

**Exactly one of `resource_group_key` or `resource_group_name_existing` must be specified.**

### Optional fields

- `location`: The location of the storage account. Defaults to `var.location`. [optional]
- `tags`: Tags to apply to the storage account. [optional]
- `account_kind`: Defaults to `StorageV2`. [optional]
- `account_tier`: Defaults to `Standard`. [optional]
- `account_replication_type`: Defaults to `ZRS`. [optional]
- `access_tier`: Defaults to `Hot`. [optional]
- `https_traffic_only_enabled`: Defaults to `true`. [optional]
- `min_tls_version`: Defaults to `TLS1_2`. [optional]
- `public_network_access_enabled`: Defaults to `false`. Set to `true` when not using private endpoints. [optional]
- `shared_access_key_enabled`: Defaults to `false`. Recommended to keep `false` and use Azure AD authentication. [optional]
- `infrastructure_encryption_enabled`: Defaults to `false`. [optional]
- `cross_tenant_replication_enabled`: Defaults to `false`. [optional]
- `blob_properties`: Blob service configuration including versioning, soft-delete, and change feed. [optional]
- `immutability_policy`: Account-level immutability policy. [optional]
- `containers`: Map of blob containers to pre-create. [optional]
- `network_rules`: Network access rules. Defaults to `Deny` all with `AzureServices` bypass. [optional]
- `private_endpoints`: Map of private endpoints to create. [optional]
- `private_endpoints_manage_dns_zone_group`: Whether this module manages private DNS zone groups. Defaults to `false` — DNS zones are typically managed at the platform level. [optional]
- `managed_identities`: Managed identity configuration. [optional]
- `role_assignments`: RBAC role assignments on the storage account. [optional]
- `lock`: Resource lock configuration. [optional]
- `diagnostic_settings_blob`: Diagnostic settings for blob storage. [optional]
- `diagnostic_settings_storage_account`: Diagnostic settings for the storage account resource. [optional]
- `enable_telemetry`: Controls AVM telemetry. Defaults to `true`. [optional]
DESCRIPTION

  validation {
    condition     = var.storage_account_enabled ? length(var.storage_accounts) > 0 : true
    error_message = "When storage_account_enabled is true, provide at least one entry in var.storage_accounts."
  }

  validation {
    condition = var.storage_account_enabled ? alltrue([
      for k, v in var.storage_accounts : (
        (try(v.resource_group_key, null) != null) != (try(v.resource_group_name_existing, null) != null)
      )
    ]) : true
    error_message = "Each storage account must have exactly one of `resource_group_key` or `resource_group_name_existing` set, but not both."
  }
}
