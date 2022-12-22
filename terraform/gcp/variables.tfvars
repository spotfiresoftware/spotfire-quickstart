#----------------------------------------
# Google project
#----------------------------------------
project_id = "my-spotfire-project"

#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox-toad"

#----------------------------------------
# Google region
#----------------------------------------
region = "europe-west2"
#zone   = "europe-west2-a"

#----------------------------------------
# Networking
#----------------------------------------
# You may want to limit the allowed addresses to reach your environment for
# admin (ssh jumphost) and web access (application)
admin_address_prefixes = ["12.34.0.0/16"]
web_address_prefixes   = ["12.0.0.0/8"]

#----------------------------------------
# Spotfire Database (tssdb)
#----------------------------------------
# https://cloud.google.com/sql/
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
#postgresql_db_version = "POSTGRES_14"
# database size in gibibytes (GiB)
#spotfire_db_size = "10"

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
ssh_public_key_file  = "~/.ssh/id_rsa_gcp.pub"
ssh_private_key_file = "~/.ssh/id_rsa_gcp"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
jumphost_instances = 1
# VM size
#jumphost_vm_size = "XS"
jumphost_instance_type = "e2-small"
# VM OS (Debian11)
#jumphost_vm_os = "debian-cloud/debian-11"
# VM login credentials
jumphost_admin_username = "spotfire"

#----------------------------------------
# TIBCO Spotfire Server (tss)
#----------------------------------------
# VM instances number
tss_instances = 3
# VM size
#tss_vm_size = "XS"
tss_instance_type = "e2-medium"
# VM OS (Debian11)
#tss_vm_os = "debian-cloud/debian-11"
# VM login credentials
tss_admin_username = "spotfire"

#----------------------------------------
# TIBCO Spotfire Web Player (wp) - Windows
#----------------------------------------
# VM instances number
wp_instances = 3
# VM size
#wp_vm_size = "XS"
wp_instance_type = "e2-medium"
# VM OS (Windows 2022)
#wp_vm_os = "windows-2022"
# VM OS (Debian 11)
wp_vm_os = "debian-cloud/debian-11"
# VM login credentials
wp_admin_username = "spotfire"
wp_admin_password = "secret0!"
