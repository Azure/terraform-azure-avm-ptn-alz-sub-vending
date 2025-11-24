# This is the root module telemetry deployment that is only created if telemetry is enabled.
# It is deployed to the created or supplied subscription
resource "azapi_resource" "telemetry_root" {
  count = var.disable_telemetry ? 0 : 1

  location  = var.location
  name      = local.telem_root_arm_deployment_name
  parent_id = local.subscription_resource_id
  type      = "Microsoft.Resources/deployments@2021-04-01"
  body = {
    properties = {
      mode     = "Incremental"
      template = local.telem_arm_subscription_template
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
resource "random_uuid" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

locals {
  avm_azapi_headers = !var.enable_telemetry ? {} : (local.fork_avm ? {
    fork_avm  = "true"
    random_id = one(random_uuid.telemetry).result
    } : {
    avm                = "true"
    random_id          = one(random_uuid.telemetry).result
    avm_module_source  = one(data.modtm_module_source.telemetry).module_source
    avm_module_version = one(data.modtm_module_source.telemetry).module_version
  })
}

locals {
  fork_avm = !anytrue([for r in local.valid_module_source_regex : can(regex(r, one(data.modtm_module_source.telemetry).module_source))])
}

locals {
  valid_module_source_regex = [
    "registry.terraform.io/[A|a]zure/.+",
    "registry.opentofu.io/[A|a]zure/.+",
    "git::https://github\\.com/[A|a]zure/.+",
    "git::ssh:://git@github\\.com/[A|a]zure/.+",
  ]
}

data "modtm_module_source" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  module_path = path.module
}

data "azapi_client_config" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

locals {
  main_location = var.location
}

resource "modtm_telemetry" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  tags = merge({
    subscription_id = one(data.azapi_client_config.telemetry).subscription_id
    tenant_id       = one(data.azapi_client_config.telemetry).tenant_id
    module_source   = one(data.modtm_module_source.telemetry).module_source
    module_version  = one(data.modtm_module_source.telemetry).module_version
    random_id       = one(random_uuid.telemetry).result
  }, { location = local.main_location })
}

locals {
  # tflint-ignore: terraform_unused_declarations
  avm_azapi_header = join(" ", [for k, v in local.avm_azapi_headers : "${k}=${v}"])
}
