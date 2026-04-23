output "custom_role_definition_id" {
  description = "The resource ID of the custom role definition."
  value       = azapi_resource.custom_role.id
}

output "test" {
  description = "The output from the subscription vending module."
  value       = module.sub_vending
}
