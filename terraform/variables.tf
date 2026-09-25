variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "rg-security-aks-dev"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-security-dev"
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username for the Linux node pool."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the Linux node pool."
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "acr_admin_password" {
  description = "Admin password for the container registry."
  type        = string
  sensitive   = true
  default     = "AcrAdminPass123!"
}

variable "storage_account_key" {
  description = "Primary access key for the storage account."
  type        = string
  sensitive   = true
  default     = "placeholder-storage-key"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    project     = "security-platform"
    environment = "dev"
    managed_by  = "terraform"
  }
}