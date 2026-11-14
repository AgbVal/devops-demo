output "container_registry" {
  value = azurerm_container_registry.acr.login_server
}

output "container_app_url" {
  value = "https://${azurerm_container_app.app.ingress[0].fqdn}"
}
