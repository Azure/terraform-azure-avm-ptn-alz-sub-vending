$ErrorActionPreference = 'Stop'

$billingScope = [Environment]::GetEnvironmentVariable('TF_VAR_subscription_billing_scope')
if ([string]::IsNullOrWhiteSpace($billingScope)) {
    $billingScope = [Environment]::GetEnvironmentVariable('TF_VAR_SUBSCRIPTION_BILLING_SCOPE')
}
if ([string]::IsNullOrWhiteSpace($billingScope)) {
    return
}

$tfvarsPath = Join-Path $PSScriptRoot 'avm.auto.tfvars.json'
@{
    subscription_billing_scope = $billingScope
} | ConvertTo-Json | Set-Content -LiteralPath $tfvarsPath -Encoding utf8
