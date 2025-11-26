variable "resource_group_creation_enabled" {
  type        = bool
  default     = false
  description = "Whether to create additional resource groups in the target subscription. Requires `var.resource_groups`."
}

variable "resource_groups" {
  type = map(object({
    name         = string
    location     = optional(string)
    tags         = optional(map(string), {})
    lock_enabled = optional(bool, false)
    lock_name    = optional(string, "")
  }))
  default     = {}
  description = <<DESCRIPTION
A map of the resource groups to create. The value is an object with the following attributes:

- `name` - The name of the resource group.
- `location` - (Optional) The location of the resource group.
- `tags` - (Optional) A map of tags to assign to the resource group. Defaults to empty map.
- `lock_enabled` - (Optional) Whether to enable a resource lock on the resource group. Defaults to `false`.
- `lock_name` - (Optional) The name of the resource lock. Defaults to empty string.

We recommend that you include an entry to create the NetworkWatcherRG resource group so that this is managed by Terraform.
DESCRIPTION
  nullable    = false
}
