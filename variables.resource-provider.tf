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
The map of resource providers to register.
The map keys are the resource provider namespace, e.g. `Microsoft.Compute`.
The map values are a list of provider features to enable.
Leave the value empty to not register any resource provider features.

The default values are taken from [Hashicorp's AzureRM provider](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/internal/resourceproviders/required.go).

The resource providers in this map are for the workloads you deploy into the subscription, not for the resources this module creates. See `subscription_register_resource_providers_enabled`.
DESCRIPTION
  nullable    = false
}

variable "subscription_register_resource_providers_enabled" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Whether to register resource providers for the subscription.
Use `var.subscription_register_resource_providers_and_features` to customize registration.

Registration runs after the module's resource groups, role assignments, managed identities and virtual networks. It is for the workloads you deploy into the subscription.
Keep AzAPI provider registration on, because the resources this module creates rely on it. If `ARM_SKIP_PROVIDER_REGISTRATION=true` is set for AzureRM, set `skip_provider_registration = false` in the `azapi` provider block.
DESCRIPTION
}
