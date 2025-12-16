variable "create_acr" {
  description = "Whether to create the Azure Container Registry"
  type        = bool
  default     = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
resource "azurerm_container_registry" "this" {
  count               = var.create_acr ? 1 : 0
  #name                = "${var.prefix}-registry"
  name                = "spotfirequickstart" # WARN: alphanumeric only for Azure container registry name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  # IMPORTANT: Private access only from whitelisted networks (requires Premium SKU)
  sku                           = "Premium"
  admin_enabled                 = false # disables anonymous access, so authentication is needed regardless of IP
  anonymous_pull_enabled        = true # anyone from allowed IP ranges can pull images without authentication
  public_network_access_enabled = true # allow public network access, but restrict by IP rules below
  data_endpoint_enabled         = true # enable data endpoint for better performance
  #network_rule_bypass_option = AzureServices

  network_rule_set {
    default_action = "Deny"

    # WARN: This fails due known azure issue: https://github.com/hashicorp/terraform-provider-azurerm/issues/20721
    # dynamic "ip_rule" {
    #   for_each = var.admin_address_prefixes
    #   content {
    #     action   = "Allow"
    #     ip_range = ip_rule.value
    #   }
    # }
    # Workaround:
    ip_rule = [
      for ip in var.admin_address_prefixes : {
        action   = "Allow"
        ip_range = ip
      }
    ]

  }

  tags = var.tags
}

