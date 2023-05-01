terraform {
  required_version = ">= 0.14"
  
  backend "azurerm" {
    environment = "public"
  }

  required_providers {
    azurerm = {
      version = "~> 2.47"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "base_name" {
  type        = string
  description = "A base for the naming scheme as part of prefix-base-suffix."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

variable "db_username" {
  type        = string
  description = "The admin username for the database."
  default     = "wpdbadmin"
}

resource "azurerm_resource_group" "rg" {
  name     = var.base_name
  location = var.location
}