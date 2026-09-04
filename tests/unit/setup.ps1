Write-Host "Copy the providers.tf file to the root module directory"

Copy-Item `
  -Path "./tests/unit/setup/providers.tf" `
  -Destination "./providers.tf" `
  -Force