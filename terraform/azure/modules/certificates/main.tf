#----------------------------------------
# Certificates
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
data "azurerm_client_config" "this" {}

resource "azurerm_key_vault" "this" {
  name                        = "spotfire-key-vault"
  location                    = var.location
  resource_group_name         = var.resource_group_name

  tags = var.tags

  enabled_for_deployment      = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.this.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.this.tenant_id
    object_id = data.azurerm_client_config.this.object_id

    certificate_permissions = [
      "backup",
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "purge",
      "recover",
      "restore",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate
resource "azurerm_key_vault_certificate" "this" {
  name         = "generated-cert"
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
  name         = "generated-certificate"
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