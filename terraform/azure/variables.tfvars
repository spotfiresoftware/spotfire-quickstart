#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox-luigi"

#----------------------------------------
# Azure location and region
#----------------------------------------
location = "North Europe"
region   = "Norway East"

#----------------------------------------
# Networking
#----------------------------------------
# You may want to limit the allowed addresses to reach your environment for
# admin (ssh jumphost) and web access (application)
admin_address_prefixes = ["12.34.0.0/16"]
web_address_prefixes   = ["12.0.0.0/8"]

#----------------------------------------
# TIBCO Spotfire Database (tssdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
# https://docs.microsoft.com/en-us/azure/postgresql/
# https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal
# https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-supported-versions
postgresql_db_version = "11"
# storage_mb: between 5120MB (5GB) and 16777216MB (16TB) for General Purpose/Memory Optimized SKUs
spotfire_db_size = "5120"

# DB server login credentials
spotfire_db_admin_username = "dbadmin"
spotfire_db_admin_password = "s3cr3t0!"

# Spotfire Admin GUI user and password
spotfire_ui_admin_username = "admin"
spotfire_ui_admin_password = "s3cr3t0!"

#----------------------------------------
# generic VM (Linux)
#----------------------------------------

# ssh key file
ssh_public_key_file  = "~/.ssh/id_rsa_azure.pub"
ssh_private_key_file = "~/.ssh/id_rsa_azure"

# --- Debian 11
os_publisher = "Debian"
os_offer     = "debian-11"
os_sku       = "11"
os_version   = "0.20221108.1193"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
#jumphost_instances = 1
# VM size
#jumphost_vm_size = "XS"
# VM login credentials
# NOTE:  The username cannot be admin/root in Azure
jumphost_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
jumphost_admin_password = "s3cr3t0!"

#----------------------------------------
# TIBCO Spotfire Server (tss)
#----------------------------------------
# VM instances number
#tss_instances = 2
# VM size
#tss_vm_size = "XS"
# VM login credentials
# NOTE:  The username cannot be admin/root in Azure
tss_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
tss_admin_password = "s3cr3t0!"

#----------------------------------------
# TIBCO Spotfire Web Player (wp) - Windows
#----------------------------------------
# VM instances number
#wp_instances = 2
# VM size
#wp_vm_size = "XS"
# VM Operating System
# --- Windows Server 2019
#wp_os_publisher = "MicrosoftWindowsServer"
#wp_os_offer     = "WindowsServer"
#wp_os_sku       = "2019-Datacenter"
#wp_os_version   = "latest"
# --- Debian 11
wp_os_publisher = "Debian"
wp_os_offer    = "debian-11"
wp_os_sku       = "11"
wp_os_version   = "0.20221108.1193"

# VM login credentials
# NOTE: The username cannot be admin/root in Azure
wp_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
wp_admin_password = "s3cr3t0!"
