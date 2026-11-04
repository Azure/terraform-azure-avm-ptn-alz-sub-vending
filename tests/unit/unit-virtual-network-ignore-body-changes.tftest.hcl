# Subnet ignore_body_changes tests (ALZ #4330)
# Proves the per-subnet setting is opt-in, survives every module layer for IPAM and
# non-IPAM subnets, and rejects conflicting or empty values.

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
}

# 1. Default is off: existing configurations are unchanged.
run "default_is_empty" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        address_space                = ["10.0.0.0/24"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name             = "snet-workload"
            address_prefixes = ["10.0.0.0/25"]
          }
        }
      }
    }
  }

  assert {
    condition     = length(var.virtual_networks["spoke"].subnets["workload"].ignore_body_changes) == 0
    error_message = "ignore_body_changes must default to an empty list (opt-in)."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# 2. Non-IPAM subnet: the value survives the root variable and the root -> internal locals.
run "non_ipam_subnet_keeps_value" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        address_space                = ["10.0.0.0/24"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name                = "snet-workload"
            address_prefixes    = ["10.0.0.0/25"]
            ignore_body_changes = ["properties.routeTable"]
          }
          managed = {
            name             = "snet-managed"
            address_prefixes = ["10.0.0.128/25"]
          }
        }
      }
    }
  }

  assert {
    condition     = contains(var.virtual_networks["spoke"].subnets["workload"].ignore_body_changes, "properties.routeTable")
    error_message = "Root variable dropped ignore_body_changes on a non-IPAM subnet."
  }
  assert {
    condition     = contains(local.virtual_networks["spoke"].subnets["workload"].ignore_body_changes, "properties.routeTable")
    error_message = "local.virtual_networks dropped ignore_body_changes before the internal module."
  }
  assert {
    condition     = length(local.virtual_networks["spoke"].subnets["managed"].ignore_body_changes) == 0
    error_message = "The setting leaked onto a subnet that did not opt in."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# 3. IPAM subnet (the reporter's subnet_ipam path).
run "ipam_subnet_keeps_value" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        resource_group_name_existing = "test-rg"
        ipam_pools = [{
          id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkManagers/test-nm/ipamPools/test-pool"
          prefix_length = 24
        }]
        subnets = {
          workload = {
            name = "snet-workload"
            ipam_pools = [{
              pool_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkManagers/test-nm/ipamPools/test-pool"
              prefix_length = 25
            }]
            ignore_body_changes = ["properties.routeTable"]
          }
        }
      }
    }
  }

  assert {
    condition     = contains(local.virtual_networks["spoke"].subnets["workload"].ignore_body_changes, "properties.routeTable")
    error_message = "ignore_body_changes was dropped on an IPAM subnet."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# 4. Internal module type keeps the value (guards against silent type-conversion drops).
run "internal_module_keeps_value" {
  command = plan

  module {
    source = "./modules/virtual-network"
  }

  variables {
    virtual_networks = {
      spoke = {
        name                = "spoke-vnet"
        address_space       = ["10.0.0.0/24"]
        resource_group_name = "test-rg"
        subnets = {
          workload = {
            name                = "snet-workload"
            address_prefixes    = ["10.0.0.0/25"]
            ignore_body_changes = ["properties.routeTable"]
          }
        }
      }
    }
  }

  assert {
    condition     = contains(var.virtual_networks["spoke"].subnets["workload"].ignore_body_changes, "properties.routeTable")
    error_message = "Internal virtual-network module type dropped ignore_body_changes."
  }
  providers = {
    azapi     = azapi
    modtm     = modtm
    random    = random
    terraform = terraform
  }
}

# 5. Terraform-owned route table without the setting still works (no regression).
run "terraform_owned_route_table_still_allowed" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        address_space                = ["10.0.0.0/24"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name             = "snet-workload"
            address_prefixes = ["10.0.0.0/25"]
            route_table = {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/rt-test"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = local.virtual_networks["spoke"].subnets["workload"].route_table != null
    error_message = "A Terraform-owned route_table must still be accepted."
  }
  providers = {
    terraform = terraform
    azapi     = azapi
    modtm     = modtm
    random    = random
    time      = time
  }
}

# 6. Conflict is rejected: route_table set AND routeTable ignored.
run "conflict_route_table_and_ignore_rejected" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        address_space                = ["10.0.0.0/24"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name                = "snet-workload"
            address_prefixes    = ["10.0.0.0/25"]
            route_table         = { key_reference = "rt1" }
            ignore_body_changes = ["properties.routeTable"]
          }
        }
      }
    }
  }

  expect_failures = [var.virtual_networks]
  providers = {
    azapi     = azapi
    modtm     = modtm
    random    = random
    terraform = terraform
    time      = time
  }
}

# 7. Empty path is rejected.
run "empty_path_rejected" {
  command = plan

  variables {
    virtual_network_enabled = true
    virtual_networks = {
      spoke = {
        name                         = "spoke-vnet"
        address_space                = ["10.0.0.0/24"]
        resource_group_name_existing = "test-rg"
        subnets = {
          workload = {
            name                = "snet-workload"
            address_prefixes    = ["10.0.0.0/25"]
            ignore_body_changes = ["  "]
          }
        }
      }
    }
  }

  expect_failures = [var.virtual_networks]
  providers = {
    azapi     = azapi
    modtm     = modtm
    random    = random
    terraform = terraform
    time      = time
  }
}
