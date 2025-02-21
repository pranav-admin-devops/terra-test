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
  name     = "pranav-prod-rg"
  location = var.location[0]
}

# resource "azurerm_resource_group" "rg1" {
#   name     = "plan-rg"
#   location = var.location[0]
# }

resource "azurerm_virtual_network" "vnet2" {
  name                = "pranav-network1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_spaces[0]
  dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
  }


resource "azurerm_subnet" "sub1" {
  name                 = "ben-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_public_ip" "pip1" {
  name                = "ben-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic1" {
  name                = "ben-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}



resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.size
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
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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




# # resource "azurerm_public_ip" "lb-ip" {
# #   name                = "lb-ip"
# #   resource_group_name = azurerm_resource_group.rg.name
# #   location            = azurerm_resource_group.rg.location
# #   allocation_method   = "Static"
# # }


# # resource "azurerm_lb" "lb1" {
# #   name                = "TestLoadBalancer"
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name
# #   frontend_ip_configuration {
# #     name                 = "PublicIPAddress"
# #     public_ip_address_id = azurerm_public_ip.lb-ip.id
# #   }
# # }


# # resource "azurerm_lb_backend_address_pool" "lb-backend-pool" {
# #   loadbalancer_id = azurerm_lb.lb1.id
# #   name            = "BackEndAddressPool"
# # }


# # resource "azurerm_lb_rule" "lb-rule" {
# #   loadbalancer_id                = azurerm_lb.lb1.id
# #   name                           = "http-rule"
# #   protocol                       = "Tcp"
# #   frontend_port                  = var.web-port
# #   backend_port                   = var.web-port
# #   frontend_ip_configuration_name = "PublicIPAddress"
# # }

# # resource "azurerm_network_interface_backend_address_pool_association" "nic-backend" {
# #   network_interface_id    = azurerm_network_interface.nic1.id
# #   ip_configuration_name   = "internal"
# #   backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend-pool.id
# # }


# # resource "azurerm_storage_account" "storage" {
# #   name                     = "pranavadminlinux"
# #   resource_group_name      = azurerm_resource_group.rg.name
# #   location                 = azurerm_resource_group.rg.location
# #   account_tier             = "Standard"
# #   account_replication_type = "LRS"
# # }

# # resource "azurerm_storage_container" "container" {
# #   name                  = "pranav-container"
# #   storage_account_id    = azurerm_storage_account.storage.id
# #   container_access_type = "private"
# # }

# # resource "azurerm_storage_blob" "example_blob" {
# #   name                   = "linux"
# #   storage_account_name   = azurerm_storage_account.storage.name
# #   storage_container_name = azurerm_storage_container.container.name
# #   type                   = "Block"
# #   source                 = "linux.txt"
# # }



# # resource "azurerm_virtual_network" "win-net" {
# #   name                = "example-network"
# #   address_space       = ["20.0.0.0/16"]
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name
# # }

# # resource "azurerm_subnet" "win-sub" {
# #   name                 = "windows"
# #   resource_group_name  = azurerm_resource_group.rg.name
# #   virtual_network_name = azurerm_virtual_network.win-net.name
# #   address_prefixes     = ["20.0.2.0/24"]
# # }

# # resource "azurerm_network_interface" "win-nic" {
# #   name                = "win-nic"
# #   location            = azurerm_resource_group.rg.location
# #   resource_group_name = azurerm_resource_group.rg.name

# #   ip_configuration {
# #     name                          = "win-internal"
# #     subnet_id                     = azurerm_subnet.win-sub.id
# #     private_ip_address_allocation = "Dynamic"
# #     public_ip_address_id = azurerm_public_ip.win-pub-ip.id
# #   }
# # }

# # resource "azurerm_public_ip" "win-pub-ip" {
# #   name                = "win-pub"
# #   resource_group_name = azurerm_resource_group.rg.name
# #   location            = azurerm_resource_group.rg.location
# #   allocation_method   = "Static"
# # }


# # resource "azurerm_windows_virtual_machine" "windows" {
# #   name                = "prnav-windows"
# #   resource_group_name = azurerm_resource_group.rg.name
# #   location            = azurerm_resource_group.rg.location
# #   size                = var.size
# #   admin_username      = "pranav"
# #   admin_password      = "Windows@123#"
# #   network_interface_ids = [
# #     azurerm_network_interface.win-nic.id,
# #   ]

# #   os_disk {
# #     caching              = "ReadWrite"
# #     storage_account_type = "Standard_LRS"
# #   }

# #   source_image_reference {
# #     publisher = "microsoftwindowsdesktop"
# #     offer     = "windows-10"
# #     sku       = "win10-22h2-pro"
# #     version   = "latest"
# #   }
# # }

# # resource "azurerm_network_interface_security_group_association" "win-SG" {
# #   network_interface_id      = azurerm_network_interface.win-nic.id
# #   network_security_group_id = azurerm_network_security_group.sg1.id
# # }


# # output "My_Public_IP" {
# #   value = azurerm_public_ip.pub-ip[0].ip_address
# # }

# # output "locations" {
# #   value = var.location[0]
# # }



# # resource "azurerm_public_ip" "pub-ip-new" {
# #   count = 4
# #   name                = "myip-${count.index}"
# #   resource_group_name = azurerm_resource_group.rg.name
# #   location            = azurerm_resource_group.rg.location
# #   allocation_method   = "Static"

# # }


# # resource "azurerm_resource_group" "rg11" {
# #   for_each = tomap(var.rg_names)
# #   name     = each.key
# #   location = each.value
# # }




# # locals {
# #   env = "prod"
# #   is_prod = local.env == "prod"

# #   vm_size = local.is_prod == "prod" ? "Standard_D2s_v3" :  local.is_prod == "dev"  ?  "Standard_F2" :  "Standard_F2" 


# #   location = "Central India"
# #   vm_name = "${local.env}-vm"
# #   rg_name = "${local.env}-rg"
# # }


# # resource "azurerm_resource_group" "rg11" {
# #   name     = local.rg_name
# #   location = local.location
# # }



# # resource "azurerm_virtual_network" "vnet" {
# #   name                = "pranav-network"
# #   location            = local.location
# #   resource_group_name = local.rg_name
# #   address_space       = var.vnet_address_spaces[0]
# #   dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
# #   }



# # resource "azurerm_subnet" "sub1" {
# #   name                 = "pranav-subnet1"
# #   resource_group_name  = local.rg_name
# #   virtual_network_name =  azurerm_virtual_network.vnet.name
# #   address_prefixes     = ["10.0.1.0/24"]
# # }


# # resource "azurerm_public_ip" "pub-ip" {
# #   name                = "ip1"
# #   resource_group_name = local.rg_name
# #   location            = local.location
# #   allocation_method   = "Static"

# # }


# # resource "azurerm_network_interface" "nic1" {
# #   name                = "example-nic"
# #   location            = local.location
# #   resource_group_name = local.rg_name

# #   ip_configuration {
# #     name                          = "internal"
# #     subnet_id                     = azurerm_subnet.sub1.id
# #     private_ip_address_allocation = "Dynamic"
# #     public_ip_address_id = azurerm_public_ip.pub-ip.id
# #   }
# # }


# # resource "azurerm_linux_virtual_machine" "vm1" {
# #   name                = local.vm_name
# #   resource_group_name = local.rg_name
# #   location            = local.location
# #   size                = local.vm_size
# #   admin_username      = "pranav"
# #   admin_password = "Ubuntu@123#"
# #   disable_password_authentication = "false"
# #   network_interface_ids = [
# #     azurerm_network_interface.nic1.id,
# #   ]

# # #   admin_ssh_key {
# # #     username   = "adminuser"
# # #     public_key = file("~/.ssh/id_rsa.pub")
# # #   }

# #   os_disk {
# #     caching              = "ReadWrite"
# #     storage_account_type = "Standard_LRS"
# #   }

# #   source_image_reference {
# #     publisher = "Canonical"
# #     offer     = "0001-com-ubuntu-server-jammy"
# #     sku       = "22_04-lts"
# #     version   = "latest"
# #   }
# # }


# # resource "azurerm_public_ip" "win-pub-ip" {
# #   name                = "win-pub${count.index}"
# #   resource_group_name = local.rg_name
# #   location            = local.location
# #   allocation_method   = "Static"
# #   count = 5
# # }


# # output "My-IPs" {
# #   value = [
# #     azurerm_public_ip.win-pub-ip[*].ip_address,
# #   ]
# # }


# variable "snet_prefixes1" {
#   default = ["10.0.0.0/24", "10.0.1.0/24"] 
# }


# # # List of VM names
# variable "vm_1" {
#     type = list(string)
#   default = ["vm1", "vm2"]
# }

# resource "azurerm_resource_group" "benrg" {
#  name     = "simple-rg"
#  location = var.location[0]
# }

# resource "azurerm_virtual_network" "vnet1" {
#   name                = "simple-vnet"
#   location            = azurerm_resource_group.benrg.location
#   resource_group_name = azurerm_resource_group.benrg.name
#   address_space       = ["10.0.0.0/16"]
#   }

# resource "azurerm_subnet" "sub1" {
#   count             = length(var.snet_prefixes1)
#   name                 = "subnet-${count.index +1}"
#   resource_group_name  = azurerm_resource_group.benrg.name
#   virtual_network_name = azurerm_virtual_network.vnet1.name
#   address_prefixes     = [var.snet_prefixes1[count.index]]
# }

# resource "azurerm_network_interface" "nic1" {
#   for_each            = toset(var.vm_1)
#   name                = "${each.value}-nic"
#   location            = azurerm_resource_group.benrg.location
#   resource_group_name = azurerm_resource_group.benrg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = element(values(azurerm_subnet.sub1), index(var.vm_1, each.key)).id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_linux_virtual_machine" "vm1" {
#   for_each            = toset(var.vm_1)
#   name                = "vm-${each.value}"
#   resource_group_name = azurerm_resource_group.benrg.name
#   location            = azurerm_resource_group.benrg.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password = "hdis88732!dsaD"
#   disable_password_authentication = "false"
#   depends_on = [ azurerm_virtual_network.vnet1 ]
#   network_interface_ids = [
#     azurerm_network_interface.nic1[each.key].id,
#   ]

# #   admin_ssh_key {
# #     username   = "adminuser"
# #     public_key = file("~/.ssh/id_rsa.pub")
# #   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
# }

# output "vm_ip_addresses" {
#   value = azurerm_network_interface.nic1[*].private_ip_address
#     #azurerm_linux_virtual_machine.vm1[*].private_ip_address
#     # azurerm_virtual_network.vnet1.address_space
#     # azurerm_network_interface.nic1[*].ip_configuration[*].private_ip_address

# }



# ## The Resource group already availabel on Azure
# data "azurerm_resource_group" "demo-rg" {
#   name = "pranav-demo"

# }



# resource "azurerm_virtual_network" "vnet1" {
#   name                = "pranav-network"
#   location            = data.azurerm_resource_group.demo-rg.location
#   resource_group_name = data.azurerm_resource_group.demo-rg.name
#   address_space       = var.vnet_address_spaces[0]
#   dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
#   dynamic "subnet" {
#     for_each = var.sub
#     content {
#       name             = subnet.key
#       address_prefixes = [subnet.value]
#     }

#   }
# }

# resource "azurerm_subnet" "sub1" {
#   name                 = "pranav-subnet1"
#   resource_group_name  = data.azurerm_resource_group.demo-rg.name
#   virtual_network_name =  azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }





# output "location" {
#   value = data.azurerm_resource_group.demo-rg.location
# }



# module "linux_vm" {
#   source = "G:/vm-module"
#   rgname = "pranav-prod-rg"
#   location = "Central India"
#   username = "pranav"
#   password = "Ubuntu@123#"

# }
