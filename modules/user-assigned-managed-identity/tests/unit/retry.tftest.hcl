mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "terraform" {}

variables {
  enable_telemetry = false
  location         = "westeurope"
  name             = "test"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  federated_credentials_github = {
    branch = {
      organization = "my-organization"
      repository   = "my-repository"
      entity       = "branch"
      value        = "main"
    }
  }
}

run "retry_is_applied_to_identity_and_credentials" {
  command = plan

  variables {
    retry = {
      error_message_regex = ["MissingSubscriptionRegistration"]
    }
  }

  assert {
    condition     = azapi_resource.umi.retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The identity must retry on MissingSubscriptionRegistration."
  }

  assert {
    condition     = azapi_resource.umi_federated_credential_github_branch["branch"].retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "The federated credential must retry on MissingSubscriptionRegistration."
  }
}

run "retry_is_omitted_when_null" {
  command = plan

  assert {
    condition     = azapi_resource.umi.retry == null
    error_message = "No retry must be set when none is supplied."
  }
}
