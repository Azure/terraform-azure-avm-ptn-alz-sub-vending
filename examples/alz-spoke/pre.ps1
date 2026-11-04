$ErrorActionPreference = 'Stop'

$billingScope = [Environment]::GetEnvironmentVariable('TF_VAR_subscription_billing_scope')
if ([string]::IsNullOrWhiteSpace($billingScope)) {
    $billingScope = [Environment]::GetEnvironmentVariable('TF_VAR_SUBSCRIPTION_BILLING_SCOPE')
}
$managementGroupId = [Environment]::GetEnvironmentVariable('TF_VAR_subscription_management_group_id')
if ([string]::IsNullOrWhiteSpace($managementGroupId)) {
    $managementGroupId = [Environment]::GetEnvironmentVariable('TF_VAR_SUBSCRIPTION_MANAGEMENT_GROUP_ID')
}

$tfvars = @{}
if (-not [string]::IsNullOrWhiteSpace($billingScope)) {
    $tfvars.subscription_billing_scope = $billingScope
}
if (-not [string]::IsNullOrWhiteSpace($managementGroupId)) {
    $tfvars.subscription_management_group_id = $managementGroupId
}
if ($tfvars.Count -eq 0) {
    return
}

$tfvarsPath = Join-Path $PSScriptRoot 'avm.auto.tfvars.json'
$tfvars | ConvertTo-Json | Set-Content -LiteralPath $tfvarsPath -Encoding utf8
