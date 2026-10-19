variable "location" {
  type        = string
  description = "The Azure region for this module's resources or telemetry deployment."
  nullable    = false
}

variable "resource_provider" {
  type        = string
  description = <<DESCRIPTION
The resource provider namespace, e.g. `Microsoft.Compute`.
DESCRIPTION
  nullable    = false
}

variable "subscription_id" {
  type        = string
  description = <<DESCRIPTION
The subscription id to register the resource providers in.
DESCRIPTION
  nullable    = false

  validation {
    condition     = can(regex("^[a-f\\d]{4}(?:[a-f\\d]{4}-){4}[a-f\\d]{12}$", var.subscription_id))
    error_message = "subscription_id must be set"
  }
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

variable "features" {
  type        = set(string)
  default     = []
  description = <<DESCRIPTION
The resource provider features to register, e.g. [`MyFeature`]
DESCRIPTION
  nullable    = false
}
