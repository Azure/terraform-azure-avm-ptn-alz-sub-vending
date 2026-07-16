output "name" {
  description = "The name of the route table."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the route table."
  value       = azapi_resource.this.id
}

output "routes" {
  description = "A map of route names to their resource IDs."
  value       = { for k, v in module.route : k => v.resource_id }
}
