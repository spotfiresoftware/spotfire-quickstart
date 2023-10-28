#
#resource "azuread_application" "this" {
#  display_name = "${var.prefix}-principal"
#}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
#resource "azuread_service_principal" "this" {
#  application_id = azuread_application.this.application_id
#}
#
#resource "azuread_service_principal_password" "this" {
#  service_principal_id = azuread_service_principal.this.object_id
#}

## User Assigned Identities
resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  name                = "${var.prefix}-user-identity"

  tags = var.tags
}

resource "azurerm_role_assignment" "ra1" {
  scope                = azurerm_subnet.k8s_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = var.aks_service_principal_object_id

  depends_on = [azurerm_virtual_network.this]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.this.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_service_principal_object_id
  depends_on           = [azurerm_user_assigned_identity.this]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.network.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  depends_on = [
    azurerm_user_assigned_identity.this,
    azurerm_application_gateway.network,
  ]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  depends_on = [
    azurerm_user_assigned_identity.this,
    azurerm_application_gateway.network,
  ]
}