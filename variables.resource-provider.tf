variable "subscription_register_resource_providers_and_features" {
  type = map(set(string))
  default = {
    "Microsoft.ApiManagement"           = [],
    "Microsoft.AppPlatform"             = [],
    "Microsoft.Authorization"           = [],
    "Microsoft.Automation"              = [],
    "Microsoft.AVS"                     = [],
    "Microsoft.Blueprint"               = [],
    "Microsoft.BotService"              = [],
    "Microsoft.Cache"                   = [],
    "Microsoft.Cdn"                     = [],
    "Microsoft.CognitiveServices"       = [],
    "Microsoft.Compute"                 = [],
    "Microsoft.ContainerInstance"       = [],
    "Microsoft.ContainerRegistry"       = [],
    "Microsoft.ContainerService"        = [],
    "Microsoft.Consumption"             = [],
    "Microsoft.CostManagement"          = [],
    "Microsoft.CustomProviders"         = [],
    "Microsoft.Databricks"              = [],
    "Microsoft.DataLakeAnalytics"       = [],
    "Microsoft.DataLakeStore"           = [],
    "Microsoft.DataMigration"           = [],
    "Microsoft.DataProtection"          = [],
    "Microsoft.DBforMariaDB"            = [],
    "Microsoft.DBforMySQL"              = [],
    "Microsoft.DBforPostgreSQL"         = [],
    "Microsoft.DesktopVirtualization"   = [],
    "Microsoft.Devices"                 = [],
    "Microsoft.DevTestLab"              = [],
    "Microsoft.DocumentDB"              = [],
    "Microsoft.EventGrid"               = [],
    "Microsoft.EventHub"                = [],
    "Microsoft.HDInsight"               = [],
    "Microsoft.HealthcareApis"          = [],
    "Microsoft.GuestConfiguration"      = [],
    "Microsoft.KeyVault"                = [],
    "Microsoft.Kusto"                   = [],
    "microsoft.insights"                = [],
    "Microsoft.Logic"                   = [],
    "Microsoft.MachineLearningServices" = [],
    "Microsoft.Maintenance"             = [],
    "Microsoft.ManagedIdentity"         = [],
    "Microsoft.ManagedServices"         = [],
    "Microsoft.Management"              = [],
    "Microsoft.Maps"                    = [],
    "Microsoft.MarketplaceOrdering"     = [],
    "Microsoft.Network"                 = [],
    "Microsoft.NotificationHubs"        = [],
    "Microsoft.OperationalInsights"     = [],
    "Microsoft.OperationsManagement"    = [],
    "Microsoft.PolicyInsights"          = [],
    "Microsoft.PowerBIDedicated"        = [],
    "Microsoft.Relay"                   = [],
    "Microsoft.RecoveryServices"        = [],
    "Microsoft.Resources"               = [],
    "Microsoft.Search"                  = [],
    "Microsoft.Security"                = [],
    "Microsoft.SecurityInsights"        = [],
    "Microsoft.ServiceBus"              = [],
    "Microsoft.ServiceFabric"           = [],
    "Microsoft.Sql"                     = [],
    "Microsoft.Storage"                 = [],
    "Microsoft.StreamAnalytics"         = [],
    "Microsoft.Web"                     = [],
  }
  description = <<DESCRIPTION
The map of resource providers (and features) to register on the subscription.
The map keys are the resource provider namespace, e.g. `Microsoft.Compute`.
The map values are a list of provider features to enable.
Leave the value empty to not register any resource provider features.

Registration is performed by the `module.resourceproviders` submodule
**after** the resources managed by this module have been deployed, and is
intended to cover the resource providers needed by the **workloads** that will
subsequently be deployed into the landing-zone subscription. Resource
providers required by the resources this module itself creates are registered
on demand by the `azapi` provider at resource-creation time.

Requires `var.subscription_register_resource_providers_enabled = true`.

The default values are taken from [Hashicorp's AzureRM provider](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/internal/resourceproviders/required.go).
DESCRIPTION
  nullable    = false
}

variable "subscription_register_resource_providers_enabled" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Whether to register the resource providers (and features) listed in
`var.subscription_register_resource_providers_and_features`.

When `true`, registration is performed by `module.resourceproviders` after the
resources managed by this module have been deployed, and is intended to
pre-register the providers needed by **workloads** subsequently deployed into
the subscription. Resource providers required by the resources this module
itself creates are always registered on demand by the `azapi` provider at
resource-creation time, regardless of this setting.
DESCRIPTION
}
