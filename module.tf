# module "avm-res-network-virtualnetwork" {
#   source  = "Azure/avm-res-network-virtualnetwork/azurerm"
#   version = "0.8.1"
#   # insert the 3 required variables here
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space = ["40.0.0.0/16"]
#   location = azurerm_resource_group.rg.location
#   name = "my-test-vnet"
# }