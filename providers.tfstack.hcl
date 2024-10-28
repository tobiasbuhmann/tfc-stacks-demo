required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~>3.0"
  }
  tls = {
    source  = "hashicorp/tls"
    version = "~>4.0"
  }
  random = {
    source  = "hashicorp/random"
    version = "~>3.0"
  }
  modtm = {
    source = "azure/modtm"
    version = "~>0.3"
  }
}

provider "azurerm" "this" {
  config {
  features {}
  }
}