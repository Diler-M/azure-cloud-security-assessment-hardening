output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_kube_config" {
  description = "Raw kubeconfig for the cluster."
  value       = nonsensitive(azurerm_kubernetes_cluster.main.kube_config_raw)
  sensitive   = false
}

output "aks_admin_password" {
  description = "Admin password for the Linux node pool."
  value       = nonsensitive(var.admin_password)
  sensitive   = false
}

output "acr_login_server" {
  description = "Login server for the container registry."
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Admin username for the container registry."
  value       = azurerm_container_registry.main.admin_username
}

output "acr_admin_password" {
  description = "Admin password for the container registry."
  value       = nonsensitive(azurerm_container_registry.main.admin_password)
  sensitive   = false
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.main.name
}

output "storage_primary_access_key" {
  description = "Primary access key for the storage account."
  value       = nonsensitive(azurerm_storage_account.main.primary_access_key)
  sensitive   = false
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "aks_ssh_private_key" {
  description = "Private SSH key for the AKS node pool."
  value       = nonsensitive(tls_private_key.aks.private_key_pem)
  sensitive   = false
}