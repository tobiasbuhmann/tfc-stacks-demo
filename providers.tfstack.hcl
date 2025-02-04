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
    client_id = var.client_id
    client_secret = var.client_secret
    subscription_id = var.subscription_id
    tenant_id = var.tenant_id
  }
}

provider "tls" "this" {}
provider "random" "this" {}
provider "modtm" "this" {}