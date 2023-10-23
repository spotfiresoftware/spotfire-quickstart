#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox-mario"

#----------------------------------------
# AWS region
#----------------------------------------
region = "eu-north-1"

#----------------------------------------
# Networking
#----------------------------------------
# You may want to limit the allowed addresses to reach your environment for
# admin (ssh jumphost) and web access (application)
#admin_address_prefixes = ["12.34.0.0/16"]
#web_address_prefixes   = ["14.0.0.0/8"]

#----------------------------------------
# Spotfire Database (sfdb)
#----------------------------------------
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
# https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws
postgresql_db_version = "15"
# database size in gibibytes (GiB)
spotfire_db_size = "5"

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
#ssh_private_key_file = "/home/myuser/.ssh/id_rsa_aws.pub"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
#jumphost_instances = 1
# VM size
#jumphost_vm_size = "XS"

# VM OS (Debian)
#jumphost_vm_os = "Debian12"
# VM login credentials
#jumphost_admin_username = "admin"

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
# VM instances number
#sfs_instances = 2
# VM size
#sfs_vm_size = "XS"

# VM OS (Debian)
#sfs_vm_os = "Debian12"
# VM login credentials
#sfs_admin_username = "admin"

#----------------------------------------
# Spotfire Web Player (wp)
#----------------------------------------
# VM instances number
#sfwp_instances = 2
# VM size
#sfwp_vm_size = "XS"

# VM OS (Windows2019)
#sfwp_vm_os = "Windows2019"
# VM login credentials
#sfwp_admin_username = "spotfire"
#sfwp_admin_password = "admin"

# VM OS (Linux)
#sfwp_vm_os = "Debian11"
# VM login credentials
#sfwp_admin_username = "admin" # Debian
