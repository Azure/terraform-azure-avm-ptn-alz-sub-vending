# Testing Examples Locally

This reference covers manually testing AVM module examples against real Azure infrastructure. Each example in the `examples/` directory is an independent Terraform root module that can be deployed and validated.

## Example Directory Structure

```
<module-root>/
  examples/
    default/
      main.tf
      terraform.tf
    <other-example>/
      main.tf
      terraform.tf
```

Each subfolder under `examples/` is a standalone Terraform configuration. Test each one independently.

## Testing Workflow

For each example directory, run the following steps in order. Stop and fix or flag any errors before continuing to the next step.

### Step 1: Initialize

```bash
cd examples/<example-dir>
terraform init -upgrade
```

```powershell
Set-Location examples/<example-dir>
terraform init -upgrade
```

This downloads providers and modules at their latest compatible versions. Fix any provider constraint or module source errors before proceeding.

### Step 2: Plan

```bash
terraform plan -out=tfplan
```

```powershell
terraform plan -out=tfplan
```

Review the plan output. Look for:

- **Errors**: Fix configuration issues (missing required variables, invalid references, schema mismatches).
- **Unexpected changes**: Resources being replaced or destroyed that should be updated in-place may indicate a configuration problem.
- **Warnings**: Address deprecation warnings or provider-specific advisories.

### Step 3: Apply

```bash
terraform apply tfplan
```

```powershell
terraform apply tfplan
```

This creates the real Azure resources. Monitor for:

- **Provisioning failures**: Quota limits, naming conflicts, region availability, or permission issues.
- **Timeout errors**: Some resources take longer; check if the timeout is appropriately configured.
- **Dependency errors**: Resources that fail because a dependency wasn't ready.

Fix any errors, then re-run from Step 2 (plan) before re-applying.

### Step 4: Idempotency Check

```bash
terraform plan
```

```powershell
terraform plan
```

Run plan again **without** `-out`. The expected result is **no changes**:

```
No changes. Your infrastructure matches the configuration.
```

If changes are detected, this indicates an idempotency issue — the module or provider is not correctly round-tripping state. Common causes:

- **Default values applied server-side**: A property not set in config gets a default from Azure, causing drift. Set the default explicitly in the configuration or use `ignore_changes`.
- **Computed attributes feeding back**: An output or reference that changes on every read.
- **Provider bugs**: Some provider resources report false drift. Check for known issues.

Flag idempotency failures to the user — these are bugs that must be fixed.

### Step 5: Destroy (Optional)

**Ask the user before destroying.** They may want to:

- Manually inspect resources in the Azure portal.
- Run additional tests or validations against the live infrastructure.
- Keep resources for debugging.

If the user confirms destruction:

```bash
terraform destroy
```

```powershell
terraform destroy
```

Verify all resources are removed. Some resources (e.g., soft-delete enabled Key Vaults, managed identities with role assignments) may require manual cleanup or purging.

## Testing Multiple Examples

When the module has several examples, test each one independently:

```bash
for dir in examples/*/; do
  echo "=== Testing ${dir} ==="
  cd "${dir}"
  terraform init -upgrade
  terraform plan -out=tfplan
  terraform apply tfplan
  terraform plan  # idempotency check
  # terraform destroy  # only after user confirmation
  cd -
done
```

```powershell
foreach ($dir in Get-ChildItem -Path examples -Directory) {
  Write-Host "=== Testing $($dir.Name) ==="
  Push-Location $dir.FullName
  terraform init -upgrade
  terraform plan -out=tfplan
  terraform apply tfplan
  terraform plan  # idempotency check
  # terraform destroy  # only after user confirmation
  Pop-Location
}
```

## Distributing Examples Across Subscriptions

When testing many examples, you may want to distribute them across multiple Azure subscriptions to avoid hitting quota limits, reduce blast radius, or run them in parallel.

### Setting the Subscription Per Example

Set the `ARM_SUBSCRIPTION_ID` environment variable before running each example:

```bash
export ARM_SUBSCRIPTION_ID="<subscription-id>"
terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan
```

```powershell
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan
```

### Round-Robin Across Subscriptions

Distribute examples evenly across a pool of subscriptions:

```bash
subscriptions=(
  "00000000-0000-0000-0000-000000000001"
  "00000000-0000-0000-0000-000000000002"
  "00000000-0000-0000-0000-000000000003"
)

i=0
for dir in examples/*/; do
  export ARM_SUBSCRIPTION_ID="${subscriptions[$((i % ${#subscriptions[@]}))]}"
  echo "=== Testing ${dir} on subscription ${ARM_SUBSCRIPTION_ID} ==="
  cd "${dir}"
  terraform init -upgrade
  terraform plan -out=tfplan
  terraform apply tfplan
  terraform plan
  cd -
  i=$((i + 1))
done
```

```powershell
$subscriptions = @(
  "00000000-0000-0000-0000-000000000001"
  "00000000-0000-0000-0000-000000000002"
  "00000000-0000-0000-0000-000000000003"
)

$i = 0
foreach ($dir in Get-ChildItem -Path examples -Directory) {
  $env:ARM_SUBSCRIPTION_ID = $subscriptions[$i % $subscriptions.Count]
  Write-Host "=== Testing $($dir.Name) on subscription $env:ARM_SUBSCRIPTION_ID ==="
  Push-Location $dir.FullName
  terraform init -upgrade
  terraform plan -out=tfplan
  terraform apply tfplan
  terraform plan  # idempotency check
  Pop-Location
  $i++
}
```

### Parallel Execution Across Subscriptions

For faster testing, run examples in parallel with each pinned to a different subscription. Ensure each example uses a unique subscription to avoid resource name collisions:

```bash
subscriptions=(
  "00000000-0000-0000-0000-000000000001"
  "00000000-0000-0000-0000-000000000002"
)

i=0
for dir in examples/*/; do
  sub="${subscriptions[$((i % ${#subscriptions[@]}))]}"
  (
    export ARM_SUBSCRIPTION_ID="${sub}"
    cd "${dir}"
    terraform init -upgrade && terraform plan -out=tfplan && terraform apply tfplan && terraform plan
  ) &
  i=$((i + 1))
done
wait
```

```powershell
$subscriptions = @(
  "00000000-0000-0000-0000-000000000001"
  "00000000-0000-0000-0000-000000000002"
)

$jobs = @()
$i = 0
foreach ($dir in Get-ChildItem -Path examples -Directory) {
  $sub = $subscriptions[$i % $subscriptions.Count]
  $examplePath = $dir.FullName
  $jobs += Start-Job -ScriptBlock {
    $env:ARM_SUBSCRIPTION_ID = $using:sub
    Set-Location $using:examplePath
    terraform init -upgrade
    terraform plan -out=tfplan
    terraform apply tfplan
    terraform plan  # idempotency check
  }
  $i++
}
$jobs | Wait-Job | Receive-Job
```

## Error Handling Checklist

During each phase, watch for these common issues:

| Phase | Common Errors | Action |
|---|---|---|
| `init` | Provider version conflicts, module source not found | Fix `terraform.tf` constraints or module source references |
| `plan` | Missing required variables, invalid resource references | Add missing variables, fix references in `main.tf` |
| `apply` | Quota exceeded, naming collision, permission denied | Switch subscription, adjust names, check RBAC |
| Idempotency | Unexpected diff on re-plan | Fix drift — set server-side defaults explicitly or use `ignore_changes` |
| `destroy` | Resources stuck or soft-deleted | Purge soft-deleted resources manually, check for locks |
