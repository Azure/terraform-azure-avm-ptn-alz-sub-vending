variable "name" {
  type        = string
  description = "(Required) The name of the security rule. This needs to be unique across all Rules in the Network Security Group. Changing this forces a new resource to be created."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the network security group into which this security rule will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Network/networkSecurityGroups", var.parent_id))
    error_message = "`parent_id` must be a valid Azure network security group resource ID."
  }
}

variable "access" {
  type        = string
  description = "(Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`."
  nullable    = false

  validation {
    condition     = contains(["Allow", "Deny"], var.access)
    error_message = "Access must be either 'Allow' or 'Deny'."
  }
}

variable "direction" {
  type        = string
  description = "(Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`."
  nullable    = false

  validation {
    condition     = contains(["Inbound", "Outbound"], var.direction)
    error_message = "Direction must be either 'Inbound' or 'Outbound'."
  }
}

variable "priority" {
  type        = number
  description = "(Required) Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule."
  nullable    = false

  validation {
    condition     = var.priority >= 100 && var.priority <= 4096
    error_message = "Priority must be between 100 and 4096."
  }
}

variable "protocol" {
  type        = string
  description = "(Required) Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*` (which matches all)."
  nullable    = false

  validation {
    condition     = contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], var.protocol)
    error_message = "Protocol must be one of: 'Tcp', 'Udp', 'Icmp', 'Esp', 'Ah', or '*'."
  }
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A description for this rule. Restricted to 140 characters."
}

variable "destination_address_prefix" {
  type        = string
  default     = null
  description = "(Optional) CIDR or destination IP range or `*` to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used."
}

variable "destination_address_prefixes" {
  type        = set(string)
  default     = null
  description = "(Optional) List of destination address prefixes. Tags may not be used. This is required if `destination_address_prefix` is not specified."
}

variable "destination_application_security_group_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) A List of destination Application Security Group IDs."
}

variable "destination_port_range" {
  type        = string
  default     = null
  description = "(Optional) Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `destination_port_ranges` is not specified."
}

variable "destination_port_ranges" {
  type        = set(string)
  default     = null
  description = "(Optional) List of destination ports or port ranges. This is required if `destination_port_range` is not specified."
}

variable "source_address_prefix" {
  type        = string
  default     = null
  description = "(Optional) CIDR or source IP range or `*` to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used."
}

variable "source_address_prefixes" {
  type        = set(string)
  default     = null
  description = "(Optional) List of source address prefixes. Tags may not be used. This is required if `source_address_prefix` is not specified."
}

variable "source_application_security_group_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) A List of source Application Security Group IDs."
}

variable "source_port_range" {
  type        = string
  default     = null
  description = "(Optional) Source Port or Range. Integer or range between `0` and `65535` or `*` to match any. This is required if `source_port_ranges` is not specified."
}

variable "source_port_ranges" {
  type        = set(string)
  default     = null
  description = "(Optional) List of source ports or port ranges. This is required if `source_port_range` is not specified."
}

variable "resource_types" {
  type = object({
    this = optional(string, "Microsoft.Network/networkSecurityGroups/securityRules@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of resource types and their API versions used by this module.
The `this` key corresponds to the primary security rule resource.
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
