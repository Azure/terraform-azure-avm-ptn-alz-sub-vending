$ErrorActionPreference = 'Stop'

Write-Host 'Copy the providers.tf file to the root module directory'
$source = Join-Path $PSScriptRoot 'setup/providers.tf'
$destination = Join-Path $PSScriptRoot '../../providers.tf'
Copy-Item -LiteralPath $source -Destination $destination -Force
