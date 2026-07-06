variable "location" {
  type        = string
  description = <<DESCRIPTION
The location of the route table.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = <<DESCRIPTION
The name of the route table to create.
DESCRIPTION
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the resource group into which this route table will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid Azure resource group resource ID."
  }
}

variable "bgp_route_propagation_enabled" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
Whether BGP route propagation is enabled.
DESCRIPTION
}

variable "routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default     = []
  description = <<DESCRIPTION
A list of objects defining route tables and their associated routes to be created:

- `name` (required): The name of the route.
- `address_prefix` (required): The address prefix for the route.
- `next_hop_type` (required): The next hop type, must be one of: 'Internet', 'None', 'VirtualAppliance', 'VirtualNetworkGateway', 'VnetLocal'.
- `next_hop_in_ip_address` (optional): The next hop IP address for the route. Required if next hop type is 'VirtualAppliance'.
DESCRIPTION
  nullable    = false

  validation {
    error_message = "Next hop type must be one of: 'Internet', 'None', 'VirtualAppliance', 'VirtualNetworkGateway', 'VnetLocal'."
    condition     = alltrue([for route in var.routes : contains(["Internet", "None", "VirtualAppliance", "VirtualNetworkGateway", "VnetLocal"], route.next_hop_type)])
  }
  validation {
    error_message = "Next hop IP address must be provided if next hop type is 'VirtualAppliance'."
    condition     = alltrue([for route in var.routes : route.next_hop_type != "VirtualAppliance" || route.next_hop_in_ip_address != null])
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "resource_types" {
  type = object({
    this  = optional(string, "Microsoft.Network/routeTables@2024-05-01")
    route = optional(string, "Microsoft.Network/routeTables/routes@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of resource types and their API versions used by this module.
The `this` key corresponds to the primary route table resource.
The `route` key is cascaded to the route submodule.
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
Retry configuration applied to every `azapi` resource managed by this module.

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
Per-operation timeouts for resources managed by this module. Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
