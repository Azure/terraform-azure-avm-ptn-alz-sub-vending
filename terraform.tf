terraform {
  required_version = "~> 1.10"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.5"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
