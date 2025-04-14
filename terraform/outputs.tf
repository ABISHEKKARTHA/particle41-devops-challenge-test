output "app_url" {
  description = "URL of the SimpleTimeService application"
  value       = "http://${azurerm_public_ip.appgw.ip_address}"
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}