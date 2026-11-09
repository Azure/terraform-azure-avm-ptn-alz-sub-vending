mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "modtm" {}

mock_provider "random" {}

mock_provider "time" {}

mock_provider "terraform" {}

variables {
  location         = "uksouth"
  subscription_id  = "00000000-0000-0000-0000-000000000000"
  enable_telemetry = false

  resource_group_creation_enabled = true
  resource_groups = {
    rg1 = {
      name = "rg-retry"
    }
  }

  umi_enabled = true
  user_managed_identities = {
    umi1 = {
      name               = "umi-retry"
      resource_group_key = "rg1"
    }
  }

  budget_enabled = true
  budgets = {
    budget1 = {
      name              = "budget-retry"
      amount            = 1000
      time_grain        = "Monthly"
      time_period_start = "2026-01-01T00:00:00Z"
      time_period_end   = "2027-01-01T00:00:00Z"
      notifications = {
        actual = {
          enabled        = true
          operator       = "GreaterThan"
          threshold      = 80
          contact_emails = ["owner@example.com"]
        }
      }
    }
  }

  network_security_group_enabled = true
  network_security_groups = {
    nsg1 = {
      name               = "nsg-retry"
      location           = "uksouth"
      resource_group_key = "rg1"
    }
  }

  route_table_enabled = true
  route_tables = {
    rt1 = {
      name               = "rt-retry"
      location           = "uksouth"
      resource_group_key = "rg1"
    }
  }

  virtual_network_enabled = true
  virtual_networks = {
    vnet1 = {
      name                         = "vnet-retry"
      address_space                = ["192.168.0.0/24"]
      resource_group_name_existing = "rg-existing"
      subnets = {
        s1 = {
          name           = "snet-retry"
          address_prefix = "192.168.0.0/26"
        }
      }
    }
  }

  role_assignment_enabled = true
  role_assignments = {
    ra1 = {
      definition     = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      relative_scope = ""
      principal_id   = "11111111-1111-1111-1111-111111111111"
    }
  }
}

run "retry_defaults_to_missing_subscription_registration" {
  command = plan

  assert {
    condition     = local.retry.error_message_regex == tolist(["MissingSubscriptionRegistration"])
    error_message = "Expected MissingSubscriptionRegistration to be retried by default, got ${jsonencode(var.retry.error_message_regex)}."
  }
  providers = {
    azapi     = azapi
    modtm     = modtm
    random    = random
    terraform = terraform
    time      = time
  }
}

run "retry_can_be_turned_off" {
  command = plan

  variables {
    retry = {
      error_message_regex = []
    }
  }

  assert {
    condition     = local.retry == null
    error_message = "Expected an empty error_message_regex to pass no retry to the submodules."
  }
  providers = {
    azapi     = azapi
    modtm     = modtm
    random    = random
    terraform = terraform
    time      = time
  }
}
