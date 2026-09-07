output "name" {
  description = "The name of the network security group."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the network security group."
  value       = azapi_resource.this.id
}

output "security_rules" {
  description = "A map of security rule names to their resource IDs."
  value       = { for k, v in module.security_rule : k => v.resource_id }
}
