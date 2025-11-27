# Tests for the user managed identity module

# Test 1: Basic user managed identity
run "basic_user_managed_identity" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  }

  assert {
    condition     = var.name == "test"
    error_message = "UMI name should be 'test', got '${var.name}'"
  }

  assert {
    condition     = var.location == "westeurope"
    error_message = "UMI location should be 'westeurope', got '${var.location}'"
  }

  assert {
    condition     = length(keys(var.federated_credentials_github)) == 0
    error_message = "Expected 0 GitHub federated credentials for basic UMI, got ${length(keys(var.federated_credentials_github))}"
  }

  assert {
    condition     = length(keys(var.federated_credentials_terraform_cloud)) == 0
    error_message = "Expected 0 Terraform Cloud federated credentials for basic UMI, got ${length(keys(var.federated_credentials_terraform_cloud))}"
  }
}

# Test 2: UMI with GitHub federated credentials
run "umi_with_github_credentials" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    federated_credentials_github = {
      gh1 = {
        organization = "my-organization"
        repository   = "my-repository"
        entity       = "branch"
        value        = "my-branch"
      }
      gh2 = {
        organization = "my-organization2"
        repository   = "my-repository2"
        entity       = "pull_request"
      }
    }
  }

  assert {
    condition     = length(var.federated_credentials_github) == 2
    error_message = "Expected exactly 2 GitHub federated credentials, got ${length(var.federated_credentials_github)}"
  }

  assert {
    condition     = contains(keys(var.federated_credentials_github), "gh1") && contains(keys(var.federated_credentials_github), "gh2")
    error_message = "Expected both 'gh1' and 'gh2' GitHub credentials to be present"
  }

  assert {
    condition     = var.federated_credentials_github["gh1"].entity == "branch"
    error_message = "First credential should be for 'branch' entity, got '${var.federated_credentials_github["gh1"].entity}'"
  }

  assert {
    condition     = var.federated_credentials_github["gh2"].entity == "pull_request"
    error_message = "Second credential should be for 'pull_request' entity, got '${var.federated_credentials_github["gh2"].entity}'"
  }

  assert {
    condition     = var.federated_credentials_github["gh1"].organization == "my-organization"
    error_message = "Expected gh1 organization to be 'my-organization'"
  }
}

# Test 3: UMI with Terraform Cloud federated credentials
run "umi_with_terraform_cloud_credentials" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    federated_credentials_terraform_cloud = {
      tfc1 = {
        organization = "my-organization"
        project      = "my-repository"
        workspace    = "my-workspace"
        run_phase    = "plan"
      }
      tfc2 = {
        organization = "my-organization"
        project      = "my-repository"
        workspace    = "my-workspace"
        run_phase    = "apply"
      }
    }
  }

  assert {
    condition     = length(var.federated_credentials_terraform_cloud) == 2
    error_message = "Expected exactly 2 Terraform Cloud federated credentials, got ${length(var.federated_credentials_terraform_cloud)}"
  }

  assert {
    condition     = contains(keys(var.federated_credentials_terraform_cloud), "tfc1") && contains(keys(var.federated_credentials_terraform_cloud), "tfc2")
    error_message = "Expected both 'tfc1' and 'tfc2' Terraform Cloud credentials to be present"
  }

  assert {
    condition     = var.federated_credentials_terraform_cloud["tfc1"].run_phase == "plan"
    error_message = "First credential should be for 'plan' phase, got '${var.federated_credentials_terraform_cloud["tfc1"].run_phase}'"
  }

  assert {
    condition     = var.federated_credentials_terraform_cloud["tfc2"].run_phase == "apply"
    error_message = "Second credential should be for 'apply' phase, got '${var.federated_credentials_terraform_cloud["tfc2"].run_phase}'"
  }

  assert {
    condition     = var.federated_credentials_terraform_cloud["tfc1"].workspace == "my-workspace"
    error_message = "Expected tfc1 workspace to be 'my-workspace'"
  }
}

# Test 4: UMI with advanced federated credentials
run "umi_with_advanced_credentials" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    federated_credentials_advanced = {
      adv1 = {
        name               = "myadvancedcred1"
        subject_identifier = "field:value"
        issuer_url         = "https://test"
      }
      adv2 = {
        name               = "myadvancedcred2"
        subject_identifier = "field:value"
        issuer_url         = "https://test"
      }
    }
  }

  assert {
    condition     = length(var.federated_credentials_advanced) == 2
    error_message = "Expected exactly 2 advanced federated credentials, got ${length(var.federated_credentials_advanced)}"
  }

  assert {
    condition     = contains(keys(var.federated_credentials_advanced), "adv1") && contains(keys(var.federated_credentials_advanced), "adv2")
    error_message = "Expected both 'adv1' and 'adv2' advanced credentials to be present"
  }

  assert {
    condition     = var.federated_credentials_advanced["adv1"].issuer_url == "https://test"
    error_message = "Advanced credential should have issuer URL 'https://test', got '${var.federated_credentials_advanced["adv1"].issuer_url}'"
  }

  assert {
    condition     = var.federated_credentials_advanced["adv1"].name == "myadvancedcred1" && var.federated_credentials_advanced["adv2"].name == "myadvancedcred2"
    error_message = "Advanced credentials should have correct names"
  }
}

# Test 5: Validation test - invalid Terraform Cloud run_phase
run "invalid_terraform_cloud_run_phase" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    federated_credentials_terraform_cloud = {
      tfc1 = {
        organization = "my-organization"
        project      = "my-repository"
        workspace    = "my-workspace"
        run_phase    = "check" # Invalid - must be 'plan' or 'apply'
      }
    }
  }

  expect_failures = [
    var.federated_credentials_terraform_cloud
  ]
}

# Test 6: Validation test - invalid GitHub credentials (missing value for branch)
run "invalid_github_credentials" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    federated_credentials_github = {
      gh1 = {
        organization = "my-organization"
        repository   = "my-repository"
        entity       = "branch"
        # Missing 'value' field - required for branch entity
      }
    }
  }

  expect_failures = [
    var.federated_credentials_github
  ]
}
