terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bfhrg" {
  name     = "bfh"
  location = "East Us"
}

resource "azurerm_virtual_network" "bfhvnet" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.bfhrg.name
  location            = azurerm_resource_group.bfhrg.name
  address_space       = ["10.50.0.0/16"]


}

