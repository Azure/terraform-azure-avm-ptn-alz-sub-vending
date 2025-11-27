mock_provider "azapi" {
  override_data {
    target = module.role_definitions.data.azapi_resource_list.role_definitions
    values = {
      output = {
        value = [
          {
            "id" : "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635",
            "name" : "Owner"
            "properties" : {
              "roleName" : "Owner"
            }
          },
          {
            "id" : "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7",
            "name" : "Reader"
            "properties" : {
              "roleName" : "Reader"
            }
          },
        ]
      }
    }
  }
}

variables {
  role_assignment_principal_id = "00000000-0000-0000-0000-000000000000"
  role_assignment_scope        = "/subscriptions/00000000-0000-0000-0000-000000000000"
  role_assignment_definition   = "Owner"
}

run "simple_role_name_valid" {
  command = plan

  assert {
    condition     = azapi_resource.this.body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    error_message = "Expected roleDefinitionId to be Owner role ID '8e3af657-a8ff-443c-a75c-2fe8c4bcb635', got '${azapi_resource.this.body.properties.roleDefinitionId}'"
  }

  assert {
    condition     = azapi_resource.this.body.properties.principalId == "00000000-0000-0000-0000-000000000000"
    error_message = "Expected principalId to match '00000000-0000-0000-0000-000000000000', got '${azapi_resource.this.body.properties.principalId}'"
  }

  assert {
    condition     = var.role_assignment_definition == "Owner"
    error_message = "Expected role assignment definition to be 'Owner', got '${var.role_assignment_definition}'"
  }

  assert {
    condition     = var.role_assignment_scope == "/subscriptions/00000000-0000-0000-0000-000000000000"
    error_message = "Expected scope to be subscription level, got '${var.role_assignment_scope}'"
  }
}

run "simple_role_definition_id_valid" {
  command = plan

  variables {
    role_assignment_definition = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
  }

  assert {
    condition     = azapi_resource.this.body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    error_message = "Expected roleDefinitionId to match full role definition path, got '${azapi_resource.this.body.properties.roleDefinitionId}'"
  }

  assert {
    condition     = can(regex("^/subscriptions/.+/providers/Microsoft.Authorization/roleDefinitions/[a-f0-9-]+$", var.role_assignment_definition))
    error_message = "Expected role_assignment_definition to be a valid full role definition ID path"
  }

  assert {
    condition     = azapi_resource.this.body.properties.principalId == "00000000-0000-0000-0000-000000000000"
    error_message = "Expected principalId to be set correctly"
  }
}

run "scope_invalid" {
  command = plan

  variables {
    role_assignment_scope = "/"
  }

  expect_failures = [var.role_assignment_scope]

  # This test expects the validation to fail because "/" is not a valid scope
  # Valid scopes must be subscription, resource group, or resource level
}

run "condition_valid_v2" {
  command = plan

  variables {
    role_assignment_condition         = "(!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND NOT SubOperationMatches{'Blob.List'}))"
    role_assignment_condition_version = "2.0"
  }

  assert {
    condition     = var.role_assignment_condition_version == "2.0"
    error_message = "Expected condition version to be '2.0', got '${var.role_assignment_condition_version}'"
  }

  assert {
    condition     = var.role_assignment_condition != null && var.role_assignment_condition != ""
    error_message = "Expected role assignment condition to be set"
  }

  assert {
    condition     = can(regex("ActionMatches", var.role_assignment_condition))
    error_message = "Expected condition to contain ActionMatches clause"
  }
}


run "condition_valid_v1" {
  command = plan

  variables {
    role_assignment_condition         = "(!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND NOT SubOperationMatches{'Blob.List'}))"
    role_assignment_condition_version = "1.0"
  }

  assert {
    condition     = var.role_assignment_condition_version == "1.0"
    error_message = "Expected condition version to be '1.0', got '${var.role_assignment_condition_version}'"
  }

  assert {
    condition     = var.role_assignment_condition != null && var.role_assignment_condition != ""
    error_message = "Expected role assignment condition to be set for v1.0"
  }

  assert {
    condition     = can(regex("ActionMatches", var.role_assignment_condition))
    error_message = "Expected condition to contain ActionMatches clause"
  }
}

run "condition_invalid" {
  command = plan

  variables {
    role_assignment_condition         = "(!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND NOT SubOperationMatches{'Blob.List'}))"
    role_assignment_condition_version = "2.2"
  }

  expect_failures = [var.role_assignment_condition_version]

  # This test expects validation to fail because condition version must be either "1.0" or "2.0"
  # "2.2" is not a valid condition version
}
