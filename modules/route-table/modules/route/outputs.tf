output "name" {
  description = "The name of the route."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the route."
  value       = azapi_resource.this.id
}
