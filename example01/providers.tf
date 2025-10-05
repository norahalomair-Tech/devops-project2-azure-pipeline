terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "tfstate-rg-project2"
    storage_account_name  = "tfstate14175"
    container_name        = "tfstate"
    key                   = "project2.terraform.tfstate"
  }
}




provider "azurerm" {
  features {}
  subscription_id = "80646857-9142-494b-90c5-32fea6acbc41"
}


locals {
  resource_group_name = "project2-rg-aalhatlan"
  vnet_name           = "project2-vnet-aalhatlan"
  location            = "West Europe"
  


  tags = {
    bootcamp = "devops-week5"
  }

  address_space = ["10.0.0.0/16"]
  
  

  subnet = {
    public_subnet = {
      address_space = ["10.0.2.0/24"]
    }
    private_subnet = {
      address_space = ["10.0.3.0/24"]
    }
  }
}

