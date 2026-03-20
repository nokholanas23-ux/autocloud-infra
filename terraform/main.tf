terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "autocloud-rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "main" {
  name                = "autocloud-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "UK South"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "autocloud-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "autocloud-nic"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "autocloud-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = "UK South"
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_password                  = "Autocloud@2024!"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.main.id]
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
