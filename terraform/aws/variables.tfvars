#----------------------------------------
# Resources prefix
#----------------------------------------
prefix = "sandbox"

#----------------------------------------
# AWS region
#----------------------------------------
region = "eu-north-1"

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
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
# https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws
#postgresql_db_version = "13.1"
# database size in gibibytes (GiB)
#spotfire_db_size = "5"

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
//ssh_public_key_file  = "~/.ssh/id_rsa.pub"
//ssh_private_key_file = "~/.ssh/id_rsa"

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
//jumphost_instances = 1
# VM size
//jumphost_vm_size = "XS"
# VM OS (CentOS|openSUSE)
jumphost_vm_os = "CentOS"
# VM login credentials
jumphost_admin_username = "centos"

#----------------------------------------
# TIBCO Spotfire Server (tss)
#----------------------------------------
# VM instances number
//tss_instances = 2
# VM size
//tss_vm_size = "XS"
# VM OS (CentOS|openSUSE)
tss_vm_os = "CentOS"
# VM login credentials
tss_admin_username = "centos"

#----------------------------------------
# TIBCO Spotfire Web Player (wp) - Windows
#----------------------------------------
# VM instances number
//wp_instances = 2
# VM size
//wp_vm_size = "XS"
# VM OS (Windows2019)
//wp_vm_os = "Windows2019"
# VM login credentials
wp_admin_username = "spotfire"
wp_admin_password = "secret0!"
