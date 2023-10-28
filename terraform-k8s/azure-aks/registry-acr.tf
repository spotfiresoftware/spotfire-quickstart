# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
resource "azurerm_container_registry" "this" {
  name                = "spotfirequickstart"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  admin_enabled       = false
  sku                 = "Premium"

  # private access, only from K8s or admin IPs
  anonymous_pull_enabled        = true
  public_network_access_enabled = true
  data_endpoint_enabled         = true
  #network_rule_bypass_option = AzureServices

  network_rule_set {
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.k8s_subnet.id
    }
    ip_rule {
      action   = "Allow"
      ip_range = var.admin_address_prefixes[0]
    }

    default_action = "Deny"
  }

  # NOTE: The georeplications is only supported on new resources with the Premium SKU.
#  sku                 = "Premium"
#  georeplications {
#    location                = "East US"
#    zone_redundancy_enabled = true
#    tags                    = {}
#  }
#  georeplications {
#    location                = "North Europe"
#    zone_redundancy_enabled = true
#    tags                    = {}
#  }

  # NOTE: Need to log in to pull images
#  anonymous_pull_enabled = true
}

# method 1: azuread_service_principal
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
#data "azuread_service_principal" "aks_principal" {
#  application_id = var.appId
#}

# method 2: azurerm_user_assigned_identity
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
# This resource is created by the cluster, but not exposed by terraform directly
#data "azurerm_user_assigned_identity" "agentpool_identity" {
#  name                = "${azurerm_kubernetes_cluster.this.name}-agentpool"
#  resource_group_name = azurerm_kubernetes_cluster.this.node_resource_group
#  #depends_on          = [azurerm_kubernetes_cluster.this, azurerm_kubernetes_cluster_node_pool.worker_node_pool]
#  depends_on          = [azurerm_kubernetes_cluster.this]
#}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# The k8s node pools needs to be able to pull images from our private registry
/*
resource "azurerm_role_assignment" "acrpull_role2" {
  scope                            = azurerm_container_registry.this.id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true

# method 1: azuread_service_principal
#  principal_id                     = data.azuread_service_principal.aks_principal.id
# method 2: azurerm_user_assigned_identity
#  principal_id                     = data.azurerm_user_assigned_identity.agentpool_identity.principal_id
# method 3: kubelet_identity
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  //principal_id                     = azurerm_kubernetes_cluster.this.identity.principal_id

  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
}*/
