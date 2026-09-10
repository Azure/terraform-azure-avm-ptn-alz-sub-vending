$ErrorActionPreference = 'Stop'

$tfvarsPath = Join-Path $PSScriptRoot 'avm.auto.tfvars.json'
Remove-Item -LiteralPath $tfvarsPath -Force -ErrorAction SilentlyContinue
