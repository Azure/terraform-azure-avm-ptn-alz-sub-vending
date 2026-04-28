################################################################################
# Retry overrides
#
# Each `*_retry` variable below is forwarded to the corresponding submodule's
# own `retry` input and tunes the underlying `azapi_resource` retry behaviour.
#
# Defaults retry on `MissingSubscriptionRegistration`, returned by ARM when a
# resource provider has not yet finished registering on the subscription. This
# allows `module.resourceproviders` to run in parallel with the resource
# modules without an explicit `depends_on` ordering.
#
# Set a variable to `null` to disable retries for that submodule. Override the
# `error_message_regex` list to change the set of errors that trigger retries
# (supplying a value replaces the default list entirely).
################################################################################

variable "budget_retry" {
  type = object({
    error_message_regex  = list(string)
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default = {
    error_message_regex = ["MissingSubscriptionRegistration"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `budget` submodule's
underlying `azapi_resource`. Set to `null` to disable retries.
DESCRIPTION
}

variable "network_security_group_retry" {
  type = object({
    error_message_regex  = list(string)
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default = {
    error_message_regex = ["MissingSubscriptionRegistration"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `network-security-group`
submodule's underlying `azapi_resource`. Set to `null` to disable retries.
DESCRIPTION
}

variable "resource_group_retry" {
  type = object({
    error_message_regex  = list(string)
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default = {
    error_message_regex = ["MissingSubscriptionRegistration"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `resource-group`
submodule's underlying `azapi_resource` blocks. Set to `null` to disable retries.
DESCRIPTION
}

variable "role_assignment_retry" {
  type = object({
    error_message_regex = list(string)
    interval_seconds    = optional(number, 30)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the `role-assignment` submodule
calls created from `var.role_assignments`. Defaults to `null` (no retries).
DESCRIPTION
}

variable "role_assignment_umi_retry" {
  type = object({
    error_message_regex = list(string)
    interval_seconds    = optional(number, 30)
  })
  default = {
    error_message_regex = ["PrincipalNotFound"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the `role-assignment` submodule
calls created from the `role_assignments` property of
`var.user_managed_identities`. Defaults to retrying on `PrincipalNotFound`,
which can be returned by ARM when the user-assigned managed identity's
service principal has not yet propagated. Set to `null` to disable retries.
DESCRIPTION
}

variable "route_table_retry" {
  type = object({
    error_message_regex  = list(string)
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default = {
    error_message_regex = ["MissingSubscriptionRegistration"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local `route-table` submodule's
underlying `azapi_resource`. Set to `null` to disable retries.
DESCRIPTION
}

variable "user_managed_identity_retry" {
  type = object({
    error_message_regex  = list(string)
    interval_seconds     = optional(number, 30)
    max_interval_seconds = optional(number, 180)
  })
  default = {
    error_message_regex = ["MissingSubscriptionRegistration"]
  }
  description = <<DESCRIPTION
(Optional) Retry configuration forwarded to the local
`user-assigned-managed-identity` submodule's underlying `azapi_resource` blocks.
Set to `null` to disable retries.
DESCRIPTION
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
`Microsoft.Network` resource provider can finish registering in parallel) and
on `ReferencedResourceNotProvisioned` (preserving the upstream AVM module's
own default).
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
