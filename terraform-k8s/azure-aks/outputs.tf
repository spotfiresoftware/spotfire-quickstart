output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "AKS resource group name"
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "AKS Virtual Network name"
}

output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name"
}

output "host" {
  value       = azurerm_kubernetes_cluster.this.kube_config.0.host
  description = "AKS cluster host"
  sensitive   = true # required for root module, to confirm intend
}

output "cluster_version" {
  value       = azurerm_kubernetes_cluster.this.kubernetes_version
  description = "AKS cluster version"
}

output "num_cluster_nodes" {
  value       = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count
  description = "AKS cluster number cluster nodes"
}

# output "client_key" {
#   value = azurerm_kubernetes_cluster.this.kube_config.0.client_key
# }

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.this.kube_config_raw
# }

# output "cluster_username" {
#   value = azurerm_kubernetes_cluster.this.kube_config.0.username
# }

# output "cluster_password" {
#   value = azurerm_kubernetes_cluster.this.kube_config.0.password
# }

output "registry_url" {
  value       = azurerm_container_registry.this.login_server
  description = "Azure Container Registry (ACR) URL"
}
output "registry_name" {
  value       = azurerm_container_registry.this.name
  description = "Azure Container Registry (ACR) name"
}
