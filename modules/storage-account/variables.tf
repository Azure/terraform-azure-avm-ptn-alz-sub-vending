variable "location" {
  type        = string
  description = "The Azure region to deploy the storage account into. E.g. `eastus`"
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the storage account. Must be globally unique, between 3 and 24 characters, and consist only of lowercase letters and numbers."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3 and 24 characters, and consist only of lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the storage account into."
  nullable    = false

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "The resource_group_name must not be empty."
  }
}

variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are `Hot`, `Cool`, `Cold` and `Premium`. Defaults to `Hot`."
  nullable    = false
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "(Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Defaults to `StorageV2`."
  nullable    = false
}

variable "account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "(Optional) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. Defaults to `ZRS`."
  nullable    = false
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "(Optional) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. Defaults to `Standard`."
  nullable    = false
}

variable "blob_properties" {
  type = object({
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
  })
  default     = {}
  description = <<DESCRIPTION
Blob service properties for the storage account.

- `change_feed_enabled` - (Optional) Is the blob service properties for change feed events enabled? Defaults to `false`.
- `change_feed_retention_in_days` - (Optional) The duration of change feed events retention in days. Between 1 and 146000 days.
- `default_service_version` - (Optional) The API Version which should be used by default for requests to the Data Plane API.
- `last_access_time_enabled` - (Optional) Is last access time based tracking enabled? Defaults to `false`.
- `versioning_enabled` - (Optional) Is versioning enabled? Defaults to `true`.

`container_delete_retention_policy` block:
- `days` - (Optional) Specifies the number of days that the container should be retained, between 1 and 365. Defaults to `7`.
- `enabled` - (Optional) Is delete retention policy enabled for containers? Defaults to `true`.

`cors_rule` block:
- `allowed_headers`, `allowed_methods`, `allowed_origins`, `exposed_headers`, `max_age_in_seconds` - (Required) CORS configuration.

`delete_retention_policy` block:
- `days` - (Optional) Specifies the number of days that the blob should be retained, between 1 and 365. Defaults to `7`.
- `enabled` - (Optional) Is delete retention policy enabled for blobs? Defaults to `true`.
- `permanent_delete_enabled` - (Optional) Are soft-deleted blobs permanently deletable? Defaults to `false`.

`restore_policy` block:
- `days` - (Required) Specifies the number of days that the blob can be restored. Must be less than the `delete_retention_policy` days.
DESCRIPTION
}

variable "containers" {
  type = map(object({
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
  }))
  default     = {}
  description = <<DESCRIPTION
A map of blob containers to create within the storage account. The map key is used as the resource identifier.

- `name` - (Required) The name of the container.
- `public_access` - (Optional) The public access level. Possible values are `Container`, `Blob`, and `None`. Defaults to `None`.
- `metadata` - (Optional) A mapping of metadata to assign to the container.
- `default_encryption_scope` - (Optional) The default encryption scope for the container.
- `deny_encryption_scope_override` - (Optional) Whether to deny encryption scope override.
- `immutable_storage_with_versioning` - (Optional) Enable immutable storage with versioning for the container. Object with `enabled` (bool).
- `role_assignments` - (Optional) A map of role assignments to create on the container.
DESCRIPTION
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should cross tenant replication be enabled? Defaults to `false`."
  nullable    = false
}

variable "diagnostic_settings_blob" {
  type = map(object({
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
  }))
  default     = {}
  description = "A map of diagnostic settings to create on the Blob Storage service. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
  nullable    = false
}

variable "diagnostic_settings_storage_account" {
  type = map(object({
    name                                     = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    log_analytics_destination_type           = optional(string, "Dedicated")
    marketplace_partner_resource_id          = optional(string, null)
    metric_categories                        = optional(set(string), ["AllMetrics"])
    storage_account_resource_id              = optional(string, null)
    workspace_resource_id                    = optional(string, null)
  }))
  default     = {}
  description = "A map of diagnostic settings to create on the Storage Account resource. Supports metric categories only (`Transaction`, `AllMetrics`)."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "This variable controls whether or not telemetry is enabled for the module. For more information see https://aka.ms/avm/telemetryinfo. If it is set to false, then no telemetry will be collected."
  nullable    = false
}

variable "https_traffic_only_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Boolean flag which forces HTTPS if enabled. Defaults to `true`."
  nullable    = false
}

variable "immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    period_since_creation_in_days = number
    state                         = string
  })
  default     = null
  description = <<DESCRIPTION
Account-level immutability policy. When set, applies to all containers.

- `state` - (Required) The mode of the policy. `Disabled`, `Unlocked`, or `Locked`.
- `period_since_creation_in_days` - (Required) The immutability period in days.
- `allow_protected_append_writes` - (Required) Whether new blocks can be written to append blobs while maintaining immutability.
DESCRIPTION
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to `false`."
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "The lock level to apply to the storage account. Possible values are `None`, `CanNotDelete`, and `ReadOnly`. Default is `null` (no lock)."

  validation {
    condition     = var.lock == null ? true : contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock kind must be `CanNotDelete`, `ReadOnly`, or `None`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource.

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled. Defaults to `false`.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "(Optional) The minimum supported TLS version. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. Defaults to `TLS1_2`."
  nullable    = false
}

variable "network_rules" {
  type = object({
    bypass                     = optional(set(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Network rules for the storage account. By default all public access is denied.

- `bypass` - (Optional) Specifies whether traffic is bypassed for `Logging`, `Metrics`, `AzureServices`, or `None`. Defaults to `["AzureServices"]`.
- `default_action` - (Optional) The default action of allow or deny when no other rules match. Valid options are `Deny` or `Allow`. Defaults to `Deny`.
- `ip_rules` - (Optional) List of public IP or IP ranges in CIDR format to allow access.
- `virtual_network_subnet_ids` - (Optional) A list of virtual network subnet IDs to allow access from.

> Note: Setting `default_action` to `Allow` with `public_network_access_enabled = false` is not recommended. Ensure `public_network_access_enabled = true` when using `Allow`.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints" {
  type = map(object({
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
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the storage account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `subnet_resource_id` - (Required) The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - (Required) The service name of the private endpoint. Possible values are `blob`, `dfs`, `file`, `queue`, `table`, and `web`.
- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `location` - (Optional) The Azure location. Defaults to the storage account location.
- `resource_group_name` - (Optional) The resource group. Defaults to the storage account resource group.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. Defaults to `default`.
- `private_dns_zone_resource_ids` - (Optional) A set of private DNS zone resource IDs to associate with the private endpoint.
- `lock` - (Optional) The lock level to apply to the private endpoint.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint.
- `tags` - (Optional) Tags to apply to the private endpoint.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = false
  description = "(Optional) Whether to manage private DNS zone groups with this module. Defaults to `false` as DNS zones are typically managed at the platform level. Set to `true` only when this module should own the DNS zone group lifecycle."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether the public network access is enabled. Defaults to `false`. Set to `true` with appropriate `network_rules` when private endpoints are not used."
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    description                            = optional(string, null)
    principal_type                         = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default     = {}
  description = "A map of role assignments to create on the storage account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
  nullable    = false
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. Defaults to `false`. Recommended to keep `false` and use Azure AD authentication."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
