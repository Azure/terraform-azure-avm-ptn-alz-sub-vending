output "name" {
  description = "The name of the security rule."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the security rule."
  value       = azapi_resource.this.id
}
