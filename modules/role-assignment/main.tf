resource "random_uuid" "this" {
  count = var.role_assignment_use_random_uuid ? 1 : 0
}

resource "time_sleep" "wait_for_role_definition" {
  count = var.role_assignment_definition_lookup_enabled && var.role_assignment_definition_lookup_delay_enabled ? 1 : 0

  create_duration = "${var.role_assignment_definition_lookup_delay_in_seconds}s"

  depends_on = [module.role_definitions]
}

module "role_definitions" {
  source  = "Azure/avm-utl-roledefinitions/azure"
  version = "0.1.0"

  enable_telemetry      = var.enable_telemetry
  role_definition_scope = var.role_assignment_scope
  use_cached_data       = !var.role_assignment_definition_lookup_enabled

  depends_on = [time_sleep.wait_for_role_definition]
}

resource "azapi_resource" "this" {
  name      = var.role_assignment_use_random_uuid ? random_uuid.this[0].result : uuidv5("url", "${var.role_assignment_scope}${var.role_assignment_principal_id}${local.role_definition_id_final}")
  parent_id = var.role_assignment_scope
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = var.role_assignment_principal_id
      roleDefinitionId = local.role_definition_id
      condition        = var.role_assignment_condition
      conditionVersion = var.role_assignment_condition_version
      principalType    = var.role_assignment_principal_type
    }
  }
  ignore_null_property = true
  retry                = var.retry

  lifecycle {
    precondition {
      condition     = local.role_definition_id != null
      error_message = "In `var.role_assignment_definition` - either supply the role assignment definition resource id or a valid role assignment definition name (and make sure that role definition lookup is enabled). If this is a custom RBAC role that may take some time to propogate due to the subscription placement, consider enabling the retry mechanism for role definition lookup with the variable `role_assignment_definition_lookup_delay_enabled`."
    }
  }
}
