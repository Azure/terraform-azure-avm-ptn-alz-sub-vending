variable "address_prefix" {
  type        = string
  description = "(Required) The destination CIDR to which the route applies."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the route."
  nullable    = false
}

variable "next_hop_type" {
  type        = string
  description = "(Required) The type of Azure hop the packet should be sent to. Possible values are `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`."
  nullable    = false

  validation {
    condition     = contains(["Internet", "None", "VirtualAppliance", "VirtualNetworkGateway", "VnetLocal"], var.next_hop_type)
    error_message = "Next hop type must be one of: 'Internet', 'None', 'VirtualAppliance', 'VirtualNetworkGateway', 'VnetLocal'."
  }
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the route table into which this route will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Network/routeTables", var.parent_id))
    error_message = "`parent_id` must be a valid Azure route table resource ID."
  }
}

variable "next_hop_in_ip_address" {
  type        = string
  default     = null
  description = "(Optional) The IP address packets should be forwarded to. Required when `next_hop_type` is `VirtualAppliance`."
}

variable "resource_types" {
  type = object({
    this = optional(string, "Microsoft.Network/routeTables/routes@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of resource types and their API versions used by this module.
The `this` key corresponds to the primary route resource.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to the `azapi` resource managed by this module.

- `error_message_regex`  - (Optional) Regex patterns matching error messages that trigger a retry.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Per-operation timeouts for this resource. Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
