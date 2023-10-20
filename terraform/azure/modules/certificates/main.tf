#----------------------------------------
# Certificates
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
data "azurerm_client_config" "this" {}

resource "azurerm_key_vault" "this" {
  # Cannot use directly ${var.prefix} variable here because:
  #   Error: "name" may only contain alphanumeric characters and dashes and must be between 3-24 chars
  # Solution: Set string length limit:
  name                = substr("${var.prefix}-key-vault", 0, 24)
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.this.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  # If true, we get the error: autorest/azure: Service returned an error. Status=403 Code="Forbidden" Message="Public network access is disabled and request is not from a trusted service nor via an approved private link."
#  public_network_access_enabled   = false

  sku_name = "standard"

  # Need to add 'network_acls' to comply with policy: "Deny-Key vaults should restrict network access"
  # more info: https://aquasecurity.github.io/tfsec/v1.0.7/checks/azure/keyvault/specify-network-acl/
  network_acls {
    ip_rules       = var.admin_address_prefixes //  List of public IP or IP ranges in CIDR Format
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.this.tenant_id
    object_id = data.azurerm_client_config.this.object_id

    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
      "Release",
      "Rotate",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate
resource "azurerm_key_vault_certificate" "this" {
  name         = "${var.prefix}-generated-cert"
  key_vault_id = azurerm_key_vault.this.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["spotfire.mycompany.com", "spotfire.mycompany.org"]
      }

      subject            = "CN=Spotfire"
      validity_in_months = 12
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key
resource "azurerm_key_vault_key" "this" {
  name         = "${var.prefix}-generated-key"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}