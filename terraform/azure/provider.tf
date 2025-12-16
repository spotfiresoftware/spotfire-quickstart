# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}

  # Note: You could copy your subscription details within the `provider.tf` file respective fields.
  # Nevertheless, we do not recommend defining credential variables here since they could easily be checked into your version control system by mistake.
  //  subscription_id = "00000000-0000-0000-0000-000000000000"
  //  tenant_id       = "00000000-0000-0000-0000-000000000000"
  subscription_id = var.subscription_id
}
