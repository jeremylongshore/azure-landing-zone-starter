terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Local backend by default (day-one friendly).
  # After the first apply, migrate state to Azure Storage:
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-alz-tfstate"
  #   storage_account_name = "stalztfstateXXXX"
  #   container_name       = "tfstate"
  #   key                  = "landing-zone/dev.tfstate"
  # }
}

# Provider configuration lives in providers.tf
