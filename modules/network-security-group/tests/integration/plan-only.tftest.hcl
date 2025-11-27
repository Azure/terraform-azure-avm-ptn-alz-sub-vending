# Tests for the networksecuritygroup module
# Converts the tests from tests/networksecuritygroup/networksecuritygroup_test.go

# Test 1: Basic NSG without security rules
run "basic_network_security_group" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  }

  assert {
    condition     = var.name == "test"
    error_message = "NSG name should be 'test', got '${var.name}'"
  }

  assert {
    condition     = var.location == "westeurope"
    error_message = "NSG location should be 'westeurope', got '${var.location}'"
  }

  assert {
    condition     = length(keys(var.security_rules)) == 0
    error_message = "Expected 0 security rules for basic NSG, got ${length(keys(var.security_rules))}"
  }
}

# Test 2: NSG with a primary security rule
run "nsg_with_security_rule_primary" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        name                       = "test-rule"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  assert {
    condition     = length(var.security_rules) == 1
    error_message = "Expected exactly 1 security rule, got ${length(var.security_rules)}"
  }

  assert {
    condition     = contains(keys(var.security_rules), "primary")
    error_message = "Expected 'primary' security rule to be present"
  }

  assert {
    condition     = var.security_rules["primary"].name == "test-rule"
    error_message = "Security rule name should be 'test-rule', got '${var.security_rules["primary"].name}'"
  }

  assert {
    condition     = var.security_rules["primary"].priority == 100
    error_message = "Security rule priority should be 100, got ${var.security_rules["primary"].priority}"
  }
}

# Test 3: NSG with source prefixes
run "nsg_with_source_prefixes" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        destination_port_range     = "*"
        destination_address_prefix = "*"
        name                       = "test-rule"
        source_port_ranges         = ["*"]
        source_address_prefixes    = ["*"]
      }
    }
  }

  assert {
    condition     = length(var.security_rules["primary"].source_port_ranges) == 1
    error_message = "Expected exactly 1 source port range, got ${length(var.security_rules["primary"].source_port_ranges)}"
  }

  assert {
    condition     = length(var.security_rules["primary"].source_address_prefixes) == 1
    error_message = "Expected exactly 1 source address prefix, got ${length(var.security_rules["primary"].source_address_prefixes)}"
  }

  assert {
    condition     = var.security_rules["primary"].direction == "Inbound"
    error_message = "Expected direction to be 'Inbound', got '${var.security_rules["primary"].direction}'"
  }
}

# Test 4: NSG with destination prefixes
run "nsg_with_destination_prefixes" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                       = "Allow"
        direction                    = "Outbound"
        priority                     = 100
        protocol                     = "Tcp"
        source_port_range            = "*"
        source_address_prefix        = "*"
        name                         = "test-rule"
        destination_port_ranges      = ["*"]
        destination_address_prefixes = ["*"]
      }
    }
  }

  assert {
    condition     = length(var.security_rules["primary"].destination_port_ranges) == 1
    error_message = "Expected exactly 1 destination port range, got ${length(var.security_rules["primary"].destination_port_ranges)}"
  }

  assert {
    condition     = length(var.security_rules["primary"].destination_address_prefixes) == 1
    error_message = "Expected exactly 1 destination address prefix, got ${length(var.security_rules["primary"].destination_address_prefixes)}"
  }

  assert {
    condition     = var.security_rules["primary"].direction == "Outbound"
    error_message = "Expected direction to be 'Outbound', got '${var.security_rules["primary"].direction}'"
  }
}

# Test 5: NSG with all prefixes (source and destination)
run "nsg_with_all_prefixes" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                       = "Allow"
        direction                    = "Inbound"
        priority                     = 100
        protocol                     = "Tcp"
        name                         = "test-rule"
        source_port_ranges           = ["*"]
        destination_port_ranges      = ["*"]
        source_address_prefixes      = ["*"]
        destination_address_prefixes = ["*"]
      }
    }
  }

  assert {
    condition = (
      length(var.security_rules["primary"].source_port_ranges) == 1 &&
      length(var.security_rules["primary"].destination_port_ranges) == 1 &&
      length(var.security_rules["primary"].source_address_prefixes) == 1 &&
      length(var.security_rules["primary"].destination_address_prefixes) == 1
    )
    error_message = "Expected exactly 1 of each prefix type (source/dest port ranges and address prefixes)"
  }

  assert {
    condition     = var.security_rules["primary"].access == "Allow"
    error_message = "Expected access to be 'Allow', got '${var.security_rules["primary"].access}'"
  }
}

# Test 6: NSG with source application security groups
run "nsg_with_source_asgs" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        destination_address_prefix = "*"
        name                       = "test-rule"
        source_application_security_group_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sampleResourceGroup/providers/Microsoft.Network/applicationSecurityGroups/sourceASG"
        ]
      }
    }
  }

  assert {
    condition     = length(var.security_rules["primary"].source_application_security_group_ids) == 1
    error_message = "Expected exactly 1 source ASG, got ${length(var.security_rules["primary"].source_application_security_group_ids)}"
  }

  assert {
    condition     = can(regex("\\/applicationSecurityGroups\\/sourceASG$", var.security_rules["primary"].source_application_security_group_ids[0]))
    error_message = "Expected source ASG ID to end with '/applicationSecurityGroups/sourceASG', got '${var.security_rules["primary"].source_application_security_group_ids[0]}'"
  }
}

# Test 7: NSG with destination application security groups
run "nsg_with_destination_asgs" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                 = "Allow"
        direction              = "Inbound"
        priority               = 100
        protocol               = "Tcp"
        source_port_range      = "*"
        destination_port_range = "*"
        source_address_prefix  = "*"
        name                   = "test-rule"
        destination_application_security_group_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sampleResourceGroup/providers/Microsoft.Network/applicationSecurityGroups/destinationASG"
        ]
      }
    }
  }

  assert {
    condition     = length(var.security_rules["primary"].destination_application_security_group_ids) == 1
    error_message = "Expected exactly 1 destination ASG, got ${length(var.security_rules["primary"].destination_application_security_group_ids)}"
  }

  assert {
    condition     = can(regex("\\/applicationSecurityGroups\\/destinationASG$", var.security_rules["primary"].destination_application_security_group_ids[0]))
    error_message = "Expected destination ASG ID to end with '/applicationSecurityGroups/destinationASG', got '${var.security_rules["primary"].destination_application_security_group_ids[0]}'"
  }
}

# Test 8: NSG with both source and destination application security groups
run "nsg_with_all_asgs" {
  command = plan

  variables {
    name      = "test"
    location  = "westeurope"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    security_rules = {
      primary = {
        access                 = "Allow"
        direction              = "Inbound"
        priority               = 100
        protocol               = "Tcp"
        source_port_range      = "*"
        destination_port_range = "*"
        name                   = "test-rule"
        source_application_security_group_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sampleResourceGroup/providers/Microsoft.Network/applicationSecurityGroups/sourceASG"
        ]
        destination_application_security_group_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sampleResourceGroup/providers/Microsoft.Network/applicationSecurityGroups/destinationASG"
        ]
      }
    }
  }

  assert {
    condition = (
      length(var.security_rules["primary"].source_application_security_group_ids) == 1 &&
      length(var.security_rules["primary"].destination_application_security_group_ids) == 1
    )
    error_message = "Expected exactly 1 source ASG and 1 destination ASG"
  }

  assert {
    condition     = var.security_rules["primary"].protocol == "Tcp"
    error_message = "Expected protocol to be 'Tcp', got '${var.security_rules["primary"].protocol}'"
  }
}
