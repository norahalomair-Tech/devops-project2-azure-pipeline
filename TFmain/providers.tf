terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg-norah"
    storage_account_name = "tfstatenorah505"
    container_name       = "terraformstate"
    key                  = "project2-norah.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "80646857-9142-494b-90c5-32fea6acbc41"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL administrator password for the database"
  sensitive   = true
}

locals {
  resource_group_name = "project2-rg-norah"
  vnet_name           = "project2-vnet-norah"
  location            = "West Europe"

  tags = {
    bootcamp = "devops-week5"
    owner    = "norah"
  }

  address_space = ["10.0.0.0/16"]

  subnet = {
    frontend = {
      name          = "frontend-subnet"
      address_space = ["10.0.2.0/24"]
      delegation = {
        name = "frontend-appservice-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }

    backend = {
      name          = "backend-subnet"
      address_space = ["10.0.3.0/24"]
      delegation = {
        name = "backend-appservice-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }

    appgw_subnet = {
      name          = "appgw-subnet"
      address_space = ["10.0.1.0/24"]
    }

    sql = {
      name              = "sql-subnet"
      address_space     = ["10.0.4.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
  }

  nsgs = {
    frontend = {
      name           = "project2-frontend-nsg-norah"
      security_rules = []
    }

    backend = {
      name           = "project2-backend-nsg-norah"
      security_rules = []
    }

    appgw_subnet = {
      name = "project2-appgw-nsg-norah"
      security_rules = [
        {
          name                       = "AllowHttpInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
          description                = "Allow HTTP traffic from the Internet to the Application Gateway."
        },
        {
          name                       = "AllowGatewayManager"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "65200-65535"
          source_address_prefix      = "GatewayManager"
          destination_address_prefix = "*"
          description                = "Permit GatewayManager service tag for control plane operations."
        },
        {
          name                       = "AllowAzureLoadBalancer"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
          description                = "Allow Azure Load Balancer probe traffic."
        }
      ]
    }

    sql = {
      name           = "project2-sql-nsg-norah"
      security_rules = []
    }
  }
}
