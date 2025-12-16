#----------------------------------------
# Google project
#----------------------------------------
# Note: REQUIRED. Set this to your project id
project_id = "my-spotfire-project"

#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox-toad"

#----------------------------------------
# Google region & zone
#----------------------------------------
# https://cloud.google.com/compute/docs/regions-zones
region = "europe-north1"
#zone   = "europe-north1-a"

#----------------------------------------
# Networking
#----------------------------------------
# You may want to limit the allowed addresses to reach your environment for
# admin (ssh jumphost) and web access (application)
#admin_address_prefixes = ["43.21.0.0/16"]
#web_address_prefixes   = ["43.21.0.0/16"]
admin_address_prefixes = ["43.21.0.0/16"]

#----------------------------------------
# Spotfire Database (sfdb)
#----------------------------------------
# https://cloud.google.com/sql/
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
postgresql_db_version = "POSTGRES_17"
# database size in gibibytes (GiB)
spotfire_db_size = "10"
# https://cloud.google.com/sql/docs/postgres/create-instance#machine-types
# spotfire_db_instance_class = "db-f1-micro" # 1cpu 0.614GB
# spotfire_db_instance_class = "db-g1-small" # 1cpu 1.7GB
#spotfire_db_instance_class = "db-custom-2-4" # 2cpu 4GB
spotfire_db_instance_class = "db-perf-optimized-N-2"

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
ssh_public_key_file  = "~/.ssh/id_rsa_gcp.pub"
ssh_private_key_file = "~/.ssh/id_rsa_gcp"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
#jumphost_instances = 1
# VM size
#jumphost_vm_size = "XS"
jumphost_instance_type = "e2-small"
# VM OS (Debian11)
#jumphost_vm_os = "debian-cloud/debian-11"
# VM login credentials
#jumphost_admin_username = "spotfire"

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
# VM instances number
#sfs_instances = 1
# VM size
#sfs_vm_size = "XS"
sfs_instance_type = "e2-medium"
# VM OS (Debian 12)
#sfs_vm_os = "debian-cloud/debian-12"
# VM login credentials
#sfs_admin_username = "spotfire"

#----------------------------------------
# Spotfire Web Player (wp) - Windows
#----------------------------------------
# VM instances number
#sfwp_instances = 1
# VM size
#sfwp_vm_size = "XS"
sfwp_instance_type = "e2-medium"
# VM OS (Debian 12)
#sfwp_vm_os = "debian-cloud/debian-12"
# VM login credentials
#sfwp_admin_username = "spotfire"
#sfwp_admin_password = "secret0!"