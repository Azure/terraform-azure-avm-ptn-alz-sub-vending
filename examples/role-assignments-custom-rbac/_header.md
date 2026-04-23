# Custom RBAC Role Assignment Example

This example demonstrates assigning a custom RBAC role definition to a principal.

It tests the role definition lookup retry mechanism which handles the race condition
when a custom role definition may not be immediately visible after creation.
