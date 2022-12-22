#----------------------------------------
# Virtual Machines (Linux)
#----------------------------------------

# Create public IP
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-${var.role}-${count.index}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  # composed conditional creation of public ips
  //  count = var.vm_instances
  count = (var.vm_instances > 0 && var.create_public_ip) ? var.vm_instances : 0
  tags  = var.tags
}

# Create Application NICs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_interface
resource "azurerm_network_interface" "this" {
  name                = "${var.prefix}-${var.role}-${count.index}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    //    public_ip_address_id          = element(azurerm_public_ip.this.*.id,count.index)
    public_ip_address_id = var.create_public_ip ? element(azurerm_public_ip.this.*.id, count.index) : null
  }

  count = var.vm_instances

  tags = merge(var.tags, tomap({ "counter" = count.index }))
}

# Create the Linux Application VM(s)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "this" {
  name                = "${var.prefix}-${var.role}-${count.index}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  # https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
  size = var.vm_size

  # WARN: Changing admin_username or admin_password forces a new resource to be created
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  admin_ssh_key {
    username = var.vm_admin_username
    //    path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
    public_key = file(var.ssh_public_key_file)
  }

  computer_name = "${var.prefix}-${var.role}-${count.index}"

  network_interface_ids = [azurerm_network_interface.this[count.index].id]
  availability_set_id   = var.availability_set_id

  os_disk {
    name                 = "${var.prefix}-${var.role}-${count.index}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
#    disk_size_gb = "100Gb" # optional, only if bigger than VM size
  }

  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/endorsed-distros
  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  source_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
  }

  # https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-linux
  provision_vm_agent         = false
  allow_extension_operations = false

  count = var.vm_instances
  tags  = merge(var.tags, tomap({ "counter" = count.index, "role" = var.role }))
}
