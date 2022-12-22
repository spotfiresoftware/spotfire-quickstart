#----------------------------------------
# Conditional resources creation
#----------------------------------------
variable "create_spotfire_db" {
  description = "Create AWS RDS for PostgreSQL service for usage as Spotfire database"
  default     = true
}

#variable "create_alb" {
#  description = "Create AWS Application Load Balancer for HTTP access to TIBCO Spotfire Server instances (recommended if using Spotfire Server cluster)"
#  default     = true
#}

variable "create_tss_public_ip" {
  description = "Create Public IP for direct access to TIBCO Spotfire Server instances (only for testing)"
  default     = false
}

# NOTE: See documentation for differences when running Web Player on Linux
variable "create_wp_linux" {
  description = "Use Linux for Web Player services"
  default     = true
}

#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "tags" {
  type = map(string)

  default = {
    # specific tags
    description   = "Spotfire quickstart: basic install"
    app           = "Spotfire"
    app_version   = "12.0.0"
    environment   = "dev"
    infra_version = "0.2"
  }
}

variable "prefix" {
  default     = "sandbox-codename"
  description = "Prefix for resources"
}

#variable "environment" {
#  default = "dev"
#}

#----------------------------------------
# AWS region
#----------------------------------------
variable "region" {
  default = "eu-north-1"
}

#----------------------------------------
# Networking
#----------------------------------------
variable "admin_address_prefixes" {
  # Recommended to use more strict than /9 mask
  description = "CIDR or source IP range allowed for environment administration"
  default     = ["43.21.0.0/16"]
}

variable "web_address_prefixes" {
  description = "CIDR or source IP range allowed for remote access for Spotfire application"
  default     = ["43.0.0.0/8"]
}

#----------------------------------------
# Spotfire Database (tssdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html

variable "postgresql_db_version" {
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  description = "PostgreSQL data server version"
  default     = "14.3"
}

variable "spotfire_db_instance_class" {
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  description = "Spotfire database instance class"
  default = "db.t3.micro"
}

variable "spotfire_db_size" {
  description = "Spotfire database size in gibibytes (GiB)"
  # Must be an integer from 5 to 3072
  default = "5"
}

# DB server login credentials
variable "spotfire_db_admin_username" {
  description = "Spotfire database admin username"
  default     = "dbadmin"
}
variable "spotfire_db_admin_password" {
  description = "Spotfire database admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#variable "spotfire_db_server_name" {
#  description = "Spotfire database server name"
#  default     = "spotfiredb-server"
#}
variable "spotfire_db_name" {
  description = "Spotfire database name. For AWS RDS, it must begin with a letter and contain only alphanumeric characters."
  default     = "spotfiredb"
}

#----------------------------------------
# Spotfire Admin UI login credentials
#----------------------------------------
variable "spotfire_ui_admin_username" {
  description = "Spotfire web UI admin username"
  default     = "admin"
}
variable "spotfire_ui_admin_password" {
  description = "Spotfire web UI admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# generic VM (Linux)
#----------------------------------------

variable "key_name" {
  default = "ec2key"
  type    = string
}

# ssh key file
variable "ssh_public_key_file" {
  description = "Spotfire VM SSH public key file location (local)"
  default     = "~/.ssh/id_rsa_aws.pub"
}

variable "ssh_private_key_file" {
  description = "Spotfire VM SSH private key file location (local)"
  default     = "~/.ssh/id_rsa_aws"
}

#----------------------------------------
# VM Operating System
#----------------------------------------

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
# https://eu-north-1.console.aws.amazon.com/ec2/v2/home?region=eu-north-1
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
variable "aws_amis" {

  default = {
  # all images in eu-north
  #
  # openSUSE Leap 15.3
  # https://aws.amazon.com/marketplace/server/configuration?productId=5e60433b-bd08-44d8-be9e-2b774638fa6c&ref_=psb_cfg_continue
  "openSUSE" = "ami-04460796ff54dee3b"
  # CentOS 8 (x86_64) - with Updates HVM
  # https://aws.amazon.com/marketplace/server/configuration?productId=471d022d-974f-4f9c-8e39-b00d9b583833&ref_=psb_cfg_continue
  "CentOS" = "ami-0966447150c11d877"
  # RHEL_HA-8.4.0_HVM-20210504-x86_64-2-Hourly2-GP2
  "RHEL" = "ami-0baa9e2e64f3c00db"
  # Debian 11 debian-11-amd64-20211011-792
  # https://aws.amazon.com/marketplace/pp/prodview-l5gv52ndg5q6i
  "Debian11" = "ami-09561a092f2052f25"
  # Windows
  # https://aws.amazon.com/marketplace/server/configuration?productId=ef297a90-3ad0-4674-83b4-7f0ec07c39bb&ref_=psb_cfg_continue
  "Windows2019" = "ami-0de5cf558e1cb5cf9"
  }
}

variable "jumphost_vm_os" {
  default = "Debian11"
}
variable "tss_vm_os" {
  default = "Debian11"
}
variable "wp_vm_os" {
  default = "Debian11"
}

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html
#
# Usernames:
# - For Amazon Linux 2 or the Amazon Linux AMI, the user name is ec2-user.
# - For a CentOS AMI, the user name is centos.
# - For a Debian AMI, the user name is admin.
# - For a Fedora AMI, the user name is ec2-user or fedora.
# - For a RHEL AMI, the user name is ec2-user or root.
# - For a SUSE AMI, the user name is ec2-user or root.
# - For an Ubuntu AMI, the user name is ubuntu.
variable "aws_ami_user" {
  default = {
    "CentOS"      = "centos"
    "Debian"      = "admin"
    "Debian11"    = "admin"
    "openSUSE"    = "ec2-user"
    "RHEL"        = "ec2-user"
    "SUSE"        = "ec2-user"
    "Windows2019" = "spotfire"
  }
}

#----------------------------------------
# jumphost
#----------------------------------------
# VM login credentials
variable "jumphost_admin_username" {
  description = "Jumphost Server VM admin username"
  default     = "spotfire"
}

#----------------------------------------
# Spotfire Server (tss)
#----------------------------------------
# VM login credentials
variable "tss_admin_username" {
  description = "TIBCO Spotfire Server VM admin username"
  default     = "spotfire"
}

#----------------------------------------
# Web Player (wp)
#----------------------------------------
# VM login credentials
variable "wp_admin_username" {
  description = "TIBCO Spotfire Web Player VM admin username"
  default     = "spotfire"
}
variable "wp_admin_password" {
  description = "TIBCO Spotfire Web Player VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# VM instances number
#----------------------------------------
variable "jumphost_instances" {
  description = "Number of jumphost instances"
  default     = 1
}
variable "tss_instances" {
  description = "Number of TIBCO Spotfire Server instances"
  default     = 2
}
variable "wp_instances" {
  description = "Number of TIBCO Spotfire Web Player instances"
  default     = 2
}
