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

resource "azurerm_resource_group" "bfh" {
  name     = "bfh"
  location = "East Us"
  tags = {
    environment = "dev"
  }

}

resource "azurerm_virtual_network" "VNET" {
  name                = "VNET1"
  resource_group_name = azurerm_resource_group.bfh.name
  location            = azurerm_resource_group.bfh.location
  address_space       = ["10.50.0.0/16"]

}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.bfh.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.50.10.0/24"]

}

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg"
  resource_group_name = azurerm_resource_group.bfh.name
  location            = azurerm_resource_group.bfh.location


}

resource "azurerm_network_security_rule" "nsg_rule1" {
  name                        = "nsg_rule1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.bfh.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}
resource "azurerm_subnet_network_security_group_association" "nsg_ass" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id

}
resource "azurerm_public_ip" "pubip1" {
  name                = "public_ip_1"
  resource_group_name = azurerm_resource_group.bfh.name
  location            = azurerm_resource_group.bfh.location
  allocation_method   = "Dynamic"

}
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.bfh.location
  resource_group_name = azurerm_resource_group.bfh.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip1.id
  }
}
resource "azurerm_linux_virtual_machine" "lvm1" {
  name                  = "bfh-vm1"
  resource_group_name   = azurerm_resource_group.bfh.name
  location              = azurerm_resource_group.bfh.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic1.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/Users/admin/.ssh/bfhvm1key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"

  }

}