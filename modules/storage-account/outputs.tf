output "containers" {
  description = "Map of storage containers that are created."
  value       = module.storage_account.containers
}

output "name" {
  description = "The name of the storage account."
  value       = module.storage_account.name
}

output "private_endpoints" {
  description = "A map of private endpoints created on the storage account."
  value       = module.storage_account.private_endpoints
}

output "resource_id" {
  description = "The resource ID of the storage account."
  value       = module.storage_account.resource_id
}
