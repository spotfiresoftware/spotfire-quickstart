#----------------------------------------
# Virtual Machines (Windows)
#----------------------------------------

# Create Application NICs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_interface
resource "azurerm_network_interface" "this" {
  name                         = "${var.prefix}-${var.role}-${count.index}-nic"
  location                     = var.location
  resource_group_name          = var.resource_group_name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  count = var.vm_instances

  tags = merge(var.tags, tomap({"counter" = count.index}))
}

# Create the Windows Application VM(s)
#  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "this" {
  name                  = "${var.prefix}-${var.role}-${count.index}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name

  # https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
  size               = var.vm_size

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  computer_name  = "${var.prefix}-${var.role}-${count.index}"

  network_interface_ids = [azurerm_network_interface.this[count.index].id]
  availability_set_id  = var.availability_set_id

  os_disk {
    name              = "${var.prefix}-${var.role}-${count.index}-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
//    disk_size_gb = "100Gb" // optional, only if bigger than VM size
  }

  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
//  license_type = Windows_Server

  count = var.vm_instances
  tags = merge(var.tags, tomap({"counter" = count.index, "role" = var.role}))

  # https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-windows
  provision_vm_agent = true

  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  timezone= "UTC"

  winrm_listener {
    protocol = "Https"
    certificate_url = var.cert_secret_id
  }
  secret {
    key_vault_id = var.key_vault_id
    certificate {
      store = "My"
      url = var.cert_secret_id
    }
  }

}

# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
# https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-deploy-vm-extensions
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension
resource "azurerm_virtual_machine_extension" "this" {
//  name                 = "${var.prefix}-${var.role}-extension-ConfigureSSH"
  name                 = "ConfigureSSH"
//  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  virtual_machine_id   = element(azurerm_windows_virtual_machine.this.*.id, count.index)

  count = var.vm_instances

  # Windows only
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
//  autoUpgradeMinorVersion = "true"

  settings = <<SETTINGS
    {
        "fileUris": [ "${var.storage_container.id}/ConfigureSSH.ps1" ]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureSSH.ps1",
      "storageAccountName": "${var.storage_account.name}",
      "storageAccountKey": "${var.storage_account.primary_access_key}"
    }
  PROTECTED_SETTINGS

  depends_on = [ azurerm_windows_virtual_machine.this ]

  tags = var.tags
}
