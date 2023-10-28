#resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

#----------------------------------------
# Kubernetes cluster
#----------------------------------------

# AKS cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "this" {
#  name                = "${random_pet.prefix.id}-aks"
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${var.prefix}-k8s"
  kubernetes_version  = var.aks_cluster_version

  default_node_pool {
    # name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9
    name            = "default"
    node_count      = var.aks_num_nodes
    vm_size         = var.aks_machine_type
    os_disk_size_gb = var.aks_machine_disk_size
    vnet_subnet_id  = azurerm_subnet.k8s_subnet.id
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.network.id
  }

  # method 1: azuread_service_principal
#  service_principal {
#    client_id     = var.appId
#    client_secret = var.password
#  }

  # azure will assign the id automatically
  identity {
    type = "SystemAssigned"
  }

  # WARN: Changing 'role_based_access_control_enabled' forces K8s replacement
  role_based_access_control_enabled = false

  #network_profile {
    #network_plugin     = "azure"
    #dns_service_ip     = var.aks_dns_service_ip
    #service_cidr       = var.aks_service_cidr
  #}

  api_server_access_profile {
    authorized_ip_ranges = var.admin_address_prefixes
  }
  sku_tier = "Free"

  azure_policy_enabled = true

  tags = {
    environment = "dev"
    codename    = var.prefix
  }

  depends_on = [
    azurerm_virtual_network.this,
    azurerm_application_gateway.network,
  ]
}
