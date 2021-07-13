#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "santander"

#----------------------------------------
# Azure location and region
#----------------------------------------
location = "North Europe"
region   = "Norway East"

#----------------------------------------
# Networking
#----------------------------------------
# you may want to limit the traffic from your
admin_address_prefix = "85.0.0.0/8"
open_tcp_ports       = [22, 8080, 80, 443]

#----------------------------------------
# Spotfire Database (tssdb)
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
ssh_public_key_file  = "~/.ssh/id_rsa.pub"
ssh_private_key_file = "~/.ssh/id_rsa"

# VM Operating System
os_publisher = "OpenLogic"
os_distro    = "Centos"
os_sku       = "8_2"
os_version   = "8.2.2020111800"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
jumphost_instances = 1

# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
#    Size	vCore	Memory: GiB	Temp storage (SSD) GiB	Max temp storage throughput: IOPS/Read MBps/Write MBps	Max data disks/throughput: IOPS	Max NICs	Expected network bandwidth (Mbps)
#    Standard_A1_v2	1	2	10	1000/20/10	2/2x500	2	250
#    Standard_A2_v2	2	4	20	2000/40/20	4/4x500	2	500
#    Standard_A4_v2	4	8	40	4000/80/40	8/8x500	4	1000
#    Standard_A8_v2	8	16	80	8000/160/80	16/16x500	8	2000
#    ...
#    Standard_D2_v4	2	8	Remote Storage Only	4	2	1000
#    Standard_D4_v4	4	16	Remote Storage Only	8	2	2000
#    Standard_D8_v4	8	32	Remote Storage Only	16	4	4000
#    Standard_D16_v4	16	64	Remote Storage Only	32	8	8000
#    Standard_D32_v4	32	128	Remote Storage Only	32	8	16000
#    ...
jumphost_vm_size = "Standard_A1_v2" // 1cores, 2GiB, 10 GB SSD, 250Mbps

# VM login credentials
# NOTE: cannot be admin/root in Azure
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
# Spotfire Server (tss)
#----------------------------------------
# VM instances number
tss_instances = 2

# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
tss_vm_size = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
//tss_vm_size = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 4000/80/40, 8/8x500	4	1000
//tss_vm_size = "Standard_D2_v4" // 2	8	Remote Storage Only	4	2	1000
# VM login credentials
# NOTE: cannot be admin/root in Azure
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
# Web Player (wp) - Windows
#----------------------------------------
# VM instances number
wp_instances = 2

# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
wp_vm_size = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
#wp_vm_size = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 4000/80/40, 8/8x500	4	1000
//wp_vm_size = "Standard_D2_v4" // 2	8	Remote Storage Only	4	2	1000

# VM Operating System
wp_os_publisher = "MicrosoftWindowsServer"
wp_os_offer     = "WindowsServer"
wp_os_sku       = "2019-Datacenter"
wp_os_version   = "latest"

# VM login credentials
# NOTE: cannot be admin/root in Azure
wp_admin_username = "spotfire"

# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed
wp_admin_password = "s3cr3t0!"
