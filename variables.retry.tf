################################################################################
# Retry overrides
#
# Each `*_retry` variable below is forwarded to the corresponding submodule's
# own `retry` input and tunes the underlying `azapi_resource` retry behaviour.
#
# All retry variables expose the same interface:
#
#   - error_message_regex  (list(string), optional) - regex patterns matched
#     against ARM error messages; matching errors trigger a retry. When omitted
#     the submodule's own default list is used.
#   - interval_seconds     (number,       optional, default 30)
#   - max_interval_seconds (number,       optional, default 180)
#
# Defaults retry on `MissingSubscriptionRegistration`, returned by ARM when a
# resource provider has not yet finished registering on the subscription. The
# `azapi` provider registers any resource provider it needs on demand at
# resource-creation time, so the retry simply waits for that registration to
# complete. The `module.resourceproviders` submodule then runs after all the
# resource modules to register the full configured set of providers (typically
# those needed by workloads later deployed into the subscription) - see
# `var.subscription_register_resource_providers_and_features`.
#
# Override `error_message_regex` to change the set of errors that trigger
# retries. Supplying a value replaces the submodule's default list entirely.
################################################################################

variable "budget_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `budget` submodule's
underlying `azapi_resource`.
DESCRIPTION
  nullable    = false
}

variable "network_security_group_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `network-security-group`
submodule's underlying `azapi_resource`.
DESCRIPTION
  nullable    = false
}

variable "resource_group_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `resource-group`
submodule's underlying `azapi_resource` blocks.
DESCRIPTION
  nullable    = false
}

variable "role_assignment_retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the `role-assignment` submodule
calls created from `var.role_assignments`. Defaults to no retries
(`error_message_regex` unset).
DESCRIPTION
  nullable    = false
}

variable "role_assignment_umi_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["PrincipalNotFound"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the `role-assignment` submodule
calls created from the `role_assignments` property of
`var.user_managed_identities`. Defaults to retrying on `PrincipalNotFound`,
which can be returned by ARM when the user-assigned managed identity's
service principal has not yet propagated.
DESCRIPTION
  nullable    = false
}

variable "route_table_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `route-table` submodule's
underlying `azapi_resource`.
DESCRIPTION
  nullable    = false
}

variable "user_managed_identity_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local
`user-assigned-managed-identity` submodule's underlying `azapi_resource` blocks.
DESCRIPTION
  nullable    = false
}

variable "virtual_network_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration", "ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `virtual-network`
submodule. Used by the underlying `azapi_resource` blocks (including the
virtual hub connection resources) and forwarded into the AVM
`Azure/avm-res-network-virtualnetwork/azurerm` module.

Defaults to retrying on `MissingSubscriptionRegistration` (so the
`Microsoft.Network` resource provider can finish registering on demand) and on
`ReferencedResourceNotProvisioned` (preserving the upstream AVM module's own
default).
DESCRIPTION
  nullable    = false
}

variable "virtual_network_peering_retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the AVM
`Azure/avm-res-network-virtualnetwork/azurerm//modules/peering` submodule for
all hub and mesh peerings. Defaults match the upstream peering submodule's own
default of `ReferencedResourceNotProvisioned`.
DESCRIPTION
  nullable    = false
}
