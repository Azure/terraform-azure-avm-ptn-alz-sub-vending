variable "location" {
  type        = string
  description = <<DESCRIPTION
The default location of resources created by this module.
Virtual networks will be created in this location unless overridden by the `location` attribute.
DESCRIPTION
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["MissingSubscriptionRegistration"])
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = {}
  description = <<DESCRIPTION
Retry configuration applied to the `azapi` resources created for resource groups, user-assigned managed identities, role assignments, virtual networks, subnets, peerings, vWAN connections, network security groups, route tables and budgets.
A resource created in a new subscription can fail with `MissingSubscriptionRegistration` until a resource provider that is registered on demand has finished registering, so that error is retried by default.
The retry covers the delay between requesting a resource provider registration and it completing. When `subscription_register_resource_providers_enabled` is `true`, registration is requested once the subscription module has finished, alongside the resources that need it, and completes asynchronously.
If nothing registers the provider (for example `subscription_register_resource_providers_enabled` is `false` and the `azapi` provider sets `skip_provider_registration`, or the provider is not in `subscription_register_resource_providers_and_features`), a resource keeps retrying until its create timeout, 30 minutes by default, before the error is returned.
Set `error_message_regex` to `[]` to remove the `MissingSubscriptionRegistration` retry.
Role assignments also keep retrying their own transient errors with a 30 second interval, and virtual networks, subnets and peerings keep retrying `ReferencedResourceNotProvisioned`.

- `error_message_regex`  - (Optional) Regex patterns matching error messages that trigger a retry. Defaults to `["MissingSubscriptionRegistration"]`.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds. Uses the provider default when not set. Not applied to role assignments.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Uses the provider default when not set. Not applied to role assignments.
DESCRIPTION
  nullable    = false
}
