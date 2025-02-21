locals {
  vm_size = {
   default = "Standard_F2"
   prod = "Standard_D2s_v3"
   dev = "Standard_B1s"
   test = "Standard_B2s"
  }
}

locals {
  rg-names = {
   default = "pranav-defaul-rg"
   prod = "pranav-prod-rg"
   dev = "pranav-dev-rg"
   test = "pranav-test-rg"
  }
}

locals {
  rg_locations = {
   default = "estus"
   prod = "centralus"
   dev = "centralindia"
   test = "westus"
  }
}


locals {
  vm-names = {
   default = "pranav-defaul-vm"
   prod = "pranav-prod-vm"
   dev = "pranav-dev-vm"
   test = "pranav-test-vm"
  }
}


resource "azurerm_resource_group" "rg" {
  name     = local.rg-names[terraform.workspace]
  location = local.rg_locations[terraform.workspace]
}

# resource "azurerm_resource_group" "rg1" {
#   name     = "plan-rg"
#   location = var.location[0]
# }

resource "azurerm_virtual_network" "vnet2" {
  name                = "pranav-network1"
  location            = local.rg_locations[terraform.workspace]
  resource_group_name = local.rg-names[terraform.workspace]
  address_space       = var.vnet_address_spaces[0]
  dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
  }


resource "azurerm_subnet" "sub1" {
  name                 = "ben-subnet"
  resource_group_name  = local.rg-names[terraform.workspace]
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_public_ip" "pip1" {
  name                = "ben-pip"
  resource_group_name = local.rg-names[terraform.workspace]
  location            = local.rg_locations[terraform.workspace]
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic1" {
  name                = "ben-nic"
  location            = local.rg_locations[terraform.workspace]
  resource_group_name =local.rg-names[terraform.workspace]
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}



resource "azurerm_linux_virtual_machine" "vm1" {
  name                = local.vm-names[terraform.workspace]
  resource_group_name = local.rg-names[terraform.workspace]
  location            = local.rg_locations[terraform.workspace]
  size                = local.vm_size[terraform.workspace]
  admin_username      = "pranav"
  admin_password = "Ubuntu@123#"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}



resource "azurerm_network_security_group" "sg1" {
  name                = "acceptanceTestSecurityGroup1"
  location            = local.rg_locations[terraform.workspace]
  resource_group_name = local.rg-names[terraform.workspace]

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh-port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "allow-http"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.web-port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


    security_rule {
    name                       = "allow-rdp"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.rdp-port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "allow-internet"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.sg1.id
}




