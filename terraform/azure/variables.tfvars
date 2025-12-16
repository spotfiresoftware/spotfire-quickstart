#----------------------------------------
# Credentials
#----------------------------------------
# Your Azure Subscription ID
#ubscription_id = "00112233-aa44-bb55-cc66-dd7788eeff99"
subscription_id = "00729471-7a31-4c23-87b9-6ec67a79fa1d"

# You need to have sufficient permissions to create resources in the target subscription
# If you do not have sufficient permissions, please contact your Azure subscription administrator
# Assign a role within "Privileged Identity Management > My roles"
# NOTE: https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup

#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox-luigi"

#----------------------------------------
# Azure location and region
#----------------------------------------
#location = "northeurope"
#region   = "northeurope"

#----------------------------------------
# Networking
#----------------------------------------
# You may want to limit the allowed addresses to reach your environment for
# admin (ssh jumphost) and web access (application)
#admin_address_prefixes = ["43.21.0.0/16"]
#web_address_prefixes   = ["43.21.0.0/16"]
admin_address_prefixes = ["43.21.0.0/16", "158.174.208.0/24", "213.39.95.0/24"]

#----------------------------------------
# Spotfire Database (sfdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
# https://docs.microsoft.com/en-us/azure/postgresql/
# https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal
# https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-supported-versions
postgresql_db_version = "17" # only for Flexible server
# Single server: between 5120MB (5GB) and 16777216MB (16TB) for General Purpose/Memory Optimized SKUs
# Flexible server: one of [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]
#spotfire_db_size = "32768"

# The name of the SKU, follows the tier + family + cores pattern
# Single server
# https://docs.microsoft.com/rest/api/postgresql/singleserver/servers/create#sku
#spotfire_db_instance_class = "GP_Gen5_2"
# Flexible server
# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage
#spotfire_db_instance_class = "GP_Standard_D2s_v3" # General purpose, 2 vCores, 8GB
#spotfire_db_instance_class = "GP_Standard_D4s_v3" # General purpose, 4 vCores, 16GB
#spotfire_db_instance_class = "B_Standard_B1ms" # Burstable, 1 vCores, 2GB
spotfire_db_instance_class = "B_Standard_B2ms" # Burstable, 2 vCores, 4GB

# DB server login credentials
spotfire_db_admin_username = "dbadmin"
spotfire_db_admin_password = "s3cr3t0!"

# Spotfire Admin GUI user and password
spotfire_ui_admin_username = "admin"
spotfire_ui_admin_password = "s3cr3t0!"

spotfire_db_name="spotfiredb"

#----------------------------------------
# generic VM (Linux)
#----------------------------------------

# ssh key file
ssh_public_key_file  = "~/.ssh/id_rsa_azure.pub"
ssh_private_key_file = "~/.ssh/id_rsa_azure"

# --- Debian 12
os_publisher = "Debian"
os_offer     = "debian-12"
os_sku       = "12"
os_version   = "0.20251112.2294"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
#jumphost_instances = 1
# VM size
#jumphost_vm_size = "XS"
# VM login credentials
# NOTE:  The username cannot be admin/root in Azure
#jumphost_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
#jumphost_admin_password = "s3cr3t0!"

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
# VM instances number
#sfs_instances = 1
# VM size
#sfs_vm_size = "XS"
# VM login credentials
# NOTE:  The username cannot be admin/root in Azure
#sfs_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
#sfs_admin_password = "s3cr3t0!"

#----------------------------------------
# Spotfire Web Player (wp) - Windows
#----------------------------------------
# VM instances number
#sfwp_instances = 1
# VM size
#sfwp_vm_size = "XS"
# VM Operating System
# --- Debian 12
sfwp_os_publisher = "Debian"
sfwp_os_offer    = "debian-12"
sfwp_os_sku       = "12"
sfwp_os_version   = "0.20251112.2294"

# VM login credentials
# NOTE: The username cannot be admin/root in Azure
#sfwp_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
#sfwp_admin_password = "s3cr3t0!"
