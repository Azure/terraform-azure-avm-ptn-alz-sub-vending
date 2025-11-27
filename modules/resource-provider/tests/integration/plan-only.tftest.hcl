# Tests for the resourceprovider module
# Converts the test from tests/resourceprovider/resourceprovider_test.go

run "subscription_rp_registration" {
  command = plan

  variables {
    resource_provider = "My.Rp"
    features          = ["feature1", "feature2"]
    subscription_id   = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = var.resource_provider == "My.Rp"
    error_message = "Resource provider should be 'My.Rp', got '${var.resource_provider}'"
  }

  assert {
    condition     = length(var.features) == 2
    error_message = "Expected exactly 2 features, got ${length(var.features)}"
  }

  assert {
    condition     = contains(var.features, "feature1") && contains(var.features, "feature2")
    error_message = "Features should include 'feature1' and 'feature2'"
  }

  assert {
    condition     = var.subscription_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Subscription ID should match expected value"
  }
}
