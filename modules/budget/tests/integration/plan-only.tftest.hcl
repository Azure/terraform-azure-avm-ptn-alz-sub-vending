# Tests for the budget module

run "budget_scope_subscription" {
  command = plan

  variables {
    budget_name       = "budget"
    budget_scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
    budget_amount     = 1000
    budget_time_grain = "Monthly"
    budget_time_period = {
      start_date = "2024-01-01T00:00:00Z"
      end_date   = "2025-01-01T00:00:00Z"
    }
    budget_notifications = {
      notification1 = {
        enabled        = true
        operator       = "GreaterThanOrEqualTo"
        threshold      = 50
        threshold_type = "Actual"
        contact_emails = ["email1@example.com", "email2@example.com"]
      }
      notification2 = {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 75
        threshold_type = "Actual"
        contact_roles  = ["role1", "role2"]
      }
    }
  }

  assert {
    condition     = var.budget_name == "budget"
    error_message = "Budget name should be 'budget', got '${var.budget_name}'"
  }

  assert {
    condition     = var.budget_amount == 1000
    error_message = "Budget amount should be 1000, got ${var.budget_amount}"
  }

  assert {
    condition     = var.budget_time_grain == "Monthly"
    error_message = "Budget time grain should be 'Monthly', got '${var.budget_time_grain}'"
  }

  assert {
    condition     = length(var.budget_notifications) == 2
    error_message = "Expected exactly 2 budget notifications, got ${length(var.budget_notifications)}"
  }

  assert {
    condition     = contains(keys(var.budget_notifications), "notification1") && contains(keys(var.budget_notifications), "notification2")
    error_message = "Expected both 'notification1' and 'notification2' to be present"
  }

  assert {
    condition     = var.budget_notifications["notification1"].threshold == 50
    error_message = "Notification1 threshold should be 50, got ${var.budget_notifications["notification1"].threshold}"
  }

  assert {
    condition     = var.budget_notifications["notification2"].threshold == 75
    error_message = "Notification2 threshold should be 75, got ${var.budget_notifications["notification2"].threshold}"
  }

  assert {
    condition     = length(var.budget_notifications["notification1"].contact_emails) == 2
    error_message = "Expected notification1 to have exactly 2 contact emails, got ${length(var.budget_notifications["notification1"].contact_emails)}"
  }

  assert {
    condition     = length(var.budget_notifications["notification2"].contact_roles) == 2
    error_message = "Expected notification2 to have exactly 2 contact roles, got ${length(var.budget_notifications["notification2"].contact_roles)}"
  }
}
