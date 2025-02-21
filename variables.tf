variable "ssh-port" {
  type    = number
  default = 22
}

variable "web-port" {
  type    = number
  default = 80
}

variable "rdp-port" {
  default = 3389
}


variable "location" {
  type    = list(string)
  default = ["Central India", "East US", "West Europe"]

}


variable "size" {
  default = "Standard_D2s_v3"
}



variable "vnet_address_spaces" {
  type    = list(list(string))
  default = [["10.0.0.0/16"], ["192.168.0.0/16"]]
}

variable "subnet_prefixes" {
  type    = list(list(string))
  default = [["10.0.1.0/24"], ["192.168.1.0/24"]]
}


variable "is_production" {
  type    = bool
  default = true
}



# variable "rg_names" {
#   type = list(string)
#   default = [ "pranav-dev-rg", "pranav-prod-rg", "pranav-test-rg" ]
# }



variable "rg_names" {
  type = map(string)
  default = {
    dev  = "East US"
    prod = "Central India"
    test = "Central US"
  }
}

variable "client_id" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "client_secret" {}


variable "sub" {
  type = map(string)
  default = {
    sub1 = "10.0.0.0/24"
    sub2 = "10.0.1.0/24"
    sub3 = "10.0.2.0/24"
  }
}