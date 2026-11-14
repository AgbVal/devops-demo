data "azurerm_resource_group" "rg" {
  name = "tfstate-rg"
}


data "azurerm_container_app_environment" "env" {
  name                = "managedEnvironment-tfstaterg-b32f"
  resource_group_name = "tfstate-rg"
}
