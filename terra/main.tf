terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
# resource "azurerm_resource_group" "rg" {
#   name     = "secondtask1"
#   location = "West US"
# }

resource "azurerm_container_registry" "acr" {
  name                = "task1devops"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "app" {
  location            = data.azurerm_resource_group.rg.location
  name                = "task1devops-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# resource "azurerm_container_app_environment" "env" {
#   name                = "managedEnvironment-tfstaterg-a226"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
# }

resource "azurerm_container_app" "app" {
  name                         = "task1devops"
  resource_group_name          = data.azurerm_resource_group.rg.name
  container_app_environment_id = data.azurerm_container_app_environment.env.id

  revision_mode = "Single"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.app.id
    ]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "task1devops"
    #   image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      image = "task1devops.azurecr.io/demo-1:v1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled           = true
    # target_port                = 80
    target_port                = 5000
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}