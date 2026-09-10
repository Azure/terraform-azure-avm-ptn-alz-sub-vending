# This pattern module accepts subscription-relative and resource-group-key scopes,
# so the resource-module role assignment interface defined by RMFR4 and RMFR5 does not apply.
rule "avm_interface_role_assignments" {
  enabled = false
}
