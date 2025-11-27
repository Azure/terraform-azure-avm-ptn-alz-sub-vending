# Tests for the resourcegroup module
# Converts the test from tests/resourcegroup/resourcegroup_test.go

run "network_watcher_rg" {
  command = plan

  variables {
    resource_group_name = "NetworkWatcherRG"
    location            = "westeurope"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = var.resource_group_name == "NetworkWatcherRG"
    error_message = "Resource group name should be 'NetworkWatcherRG', got '${var.resource_group_name}'"
  }

  assert {
    condition     = var.location == "westeurope"
    error_message = "Resource group location should be 'westeurope', got '${var.location}'"
  }

  assert {
    condition     = var.subscription_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Subscription ID should match expected value"
  }
}
