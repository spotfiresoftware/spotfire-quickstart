#------------------------------------------------------------------------------#
# Basic Spotfire install
#------------------------------------------------------------------------------#

#----------------------------------------
# TLS private key
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "privkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.privkey.public_key_openssh
}
output "private_key" {
  value     = tls_private_key.privkey.private_key_pem
  sensitive = true
}

# Writes the AWS generated private key to a local file for usage from Ansible
variable "workspace_dir" {
  default = "./terraform.tfstate.d/"
}

#locals {
#  #ssh_priv_key_file = "${var.workspace_dir}/${terraform.workspace}/ansible_config/private_key.pem"
#  ssh_priv_key_file = "~/.ssh/aws_private_key.pem"
#}

resource "local_file" "this" {
  content = templatefile("${path.module}/private_key.pem.tmpl", {
    private_key = tls_private_key.privkey.private_key_pem
    }
  )
  #filename             = local.ssh_priv_key_file
  filename             = var.ssh_private_key_file
  file_permission      = "0600"
  directory_permission = "0700"
}

#----------------------------------------
# Virtual Machines (Linux)
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "jumphost" {
  count = var.jumphost_instances

  ami           = lookup(var.aws_amis, var.jumphost_vm_os)
  instance_type = var.jumphost_instance_type

  subnet_id = element(aws_subnet.public.*.id, count.index)

  vpc_security_group_ids = [aws_security_group.bastion.id,
    aws_security_group.mgt.id
  ]

  key_name = aws_key_pair.keypair.key_name

  associate_public_ip_address = true

  tags = merge(var.tags, tomap({
    prefix = var.prefix,
    Name   = "${var.prefix}-jumphost-${count.index}",
    role   = "jumphost_servers"
  }))
}

resource "aws_instance" "sfs" {
  count = var.sfs_instances

  ami           = lookup(var.aws_amis, var.sfs_vm_os)
  instance_type = lookup(var.sfs_instance_types, var.sfs_size)

//  subnet_id = element(aws_subnet.public.*.id, count.index)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.mgt.id, aws_security_group.sfs-web.id,
  aws_security_group.sfs-be.id, aws_security_group.sfs-cluster.id]

  key_name = aws_key_pair.keypair.key_name

  associate_public_ip_address = var.create_sfs_public_ip

  tags = merge(var.tags, tomap({
    prefix = var.prefix,
    Name   = "${var.prefix}-sfs-${count.index}",
    role   = "sfs_servers"
  }))
}

#----------------------------------------
# Virtual Machines (Windows)
#----------------------------------------

data "template_file" "windows_configure_ssh" {
  template = <<EOF
<powershell>
net user ${var.sfwp_admin_username} '${var.sfwp_admin_password}' /add /y
net localgroup administrators ${var.sfwp_admin_username} /add

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

New-NetFirewallRule -Name sshd -DisplayName 'WinRemoteDesktop (3389)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 3389
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (22)'     -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
</powershell>
<persist>true</persist>
EOF
}

resource "aws_instance" "sfwp" {
  count = var.sfwp_instances

  ami           = lookup(var.aws_amis, var.sfwp_vm_os)
  instance_type = lookup(var.sfwp_instance_types, var.sfwp_size)

//  subnet_id = element(aws_subnet.public.*.id, count.index)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.mgt.id, aws_security_group.sfs-be.id,
                            aws_security_group.sfnm.id, aws_security_group.win.id]

  associate_public_ip_address = "false"

  key_name  = aws_key_pair.keypair.key_name
  user_data = var.create_sfwp_linux ? null : data.template_file.windows_configure_ssh.rendered

  tags = merge(var.tags, tomap({
    prefix = var.prefix,
    Name   = "${var.prefix}-wp-${count.index}",
    role   = "sfwp_servers"
  }))
}

#----------------------------------------
# Security Groups
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#--- bastion ---#
resource "aws_security_group" "bastion" {
  name        = "${var.prefix}-spotfire-bastion-sg"
  description = "SSH ingress to Bastion and SSH egress to applications"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-bastion-sg"
  }

  ingress {
    description = "Allow inbound SSH from management IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_address_prefixes
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--- application mgt ---#
resource "aws_security_group" "mgt" {
  name        = "${var.prefix}-spotfire-mgt-sg"
  description = "Security group for application mgt that allows SSH and ping"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-mgt-sg"
  }

  ingress {
    description     = "Allow inbound SSH from management IPs"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    description     = "Allow inbound ICMP from management IPs"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion.id]
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--- sfs web ---#
resource "aws_security_group" "sfs-web" {
  name        = "${var.prefix}-spotfire-sfs-web-sg"
  description = "Security group for Spotfire Server (sfs) that allows web access"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-sfs-web-sg"
  }

  ingress {
    description = "Allow inbound HTTP from management addresses"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.admin_address_prefixes
  }
  ingress {
    description     = "Allow inbound HTTP traffic from Application Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-alb.id]
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--- services registration & communication ---#
resource "aws_security_group" "sfs-be" {
  name        = "${var.prefix}-spotfire-sfs-be-sg"
  description = "Spotfire Server services registration & communication  traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-sfs-be-sg"
  }

  ingress {
    description     = "Allow inbound back-end registration traffic"
    from_port       = 9080
    to_port         = 9080
    protocol        = "tcp"
    security_groups = [aws_security_group.sfs-web.id, aws_security_group.sfnm.id]
  }
  ingress {
    description     = "Allow inbound back-end communication traffic"
    from_port       = 9443
    to_port         = 9443
    protocol        = "tcp"
    security_groups = [aws_security_group.sfs-web.id, aws_security_group.sfnm.id]
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    self        = true
  }
}

#--- sfs clustering ---#
resource "aws_security_group" "sfs-cluster" {
  name        = "${var.prefix}-spotfire-sfs-cluster-sg"
  description = "Spotfire Server (sfs) cluster traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-sfs-cluster-sg"
  }

  ingress {
    description = "Allow inbound clustering traffic between sfs"
    from_port   = 5701
    to_port     = 5703
    protocol    = "tcp"
    self        = true
  }
    ingress {
      description = "Allow inbound back-end registration traffic"
      from_port   = 9080
      to_port     = 9080
      protocol    = "tcp"
      self        = true
    }
    ingress {
      description = "Allow inbound back-end communication traffic"
      from_port   = 9443
      to_port     = 9443
      protocol    = "tcp"
      self        = true
    }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    self        = true
  }
}

#--- sfnm (node manager) ---#
resource "aws_security_group" "sfnm" {
  name        = "${var.prefix}-spotfire-sfnm-sg"
  description = "Spotfire node manager (sfnm) cluster traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-sfnm-sg"
  }

  ingress {
    description     = "Allow inbound service communication from sfs nodes"
    from_port       = 9501
    to_port         = 9510
    protocol        = "tcp"
    security_groups = [aws_security_group.sfs-web.id]
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    //    self        = true
    security_groups = [aws_security_group.sfs-web.id]
  }
}

#--- windows mgt ---#
resource "aws_security_group" "win" {
  name        = "${var.prefix}-spotfire-win-sg"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-win-sg"
  }

  ingress {
    description = "Allow incoming Windows Remote Desktop from management IPs"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    //    security_groups = [aws_security_group.bastion.id]
    cidr_blocks = var.admin_address_prefixes
  }
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  db_address = var.create_spotfire_db ? aws_db_instance.this[0].address : var.spotfire_db_name
}

#----------------------------------------
# Template files
#----------------------------------------
# Generates the dynamic Ansible Inventory file
resource "local_file" "ansible-inventory-aws_ec2" {
  content = templatefile("${path.module}/host_groups_aws_ec2.yml.tmpl", {
    prefix = var.prefix,
    region = var.region
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/host_groups_aws_ec2.yml"
  file_permission      = "0770"
  directory_permission = "0770"
}

# Generates the static Ansible Inventory file
resource "local_file" "ansible-inventory-hosts_aws" {
  content = templatefile("${path.module}/ansible_inventory.tmpl", {
    # jumphost
    jumphost_hostnames     = aws_instance.jumphost[*].tags["Name"],
    jumphost_pip_addresses = aws_instance.jumphost[*].public_ip,
    jumphost_user          = lookup(var.aws_ami_user, var.jumphost_vm_os),
    # sfs
    sfs_hostnames    = aws_instance.sfs[*].tags["Name"],
    sfs_ip_addresses = aws_instance.sfs.*.private_ip,
    sfs_user         = lookup(var.aws_ami_user, var.jumphost_vm_os),
    # wp
    sfwp_hostnames    = aws_instance.sfwp[*].tags["Name"],
    sfwp_ip_addresses = aws_instance.sfwp.*.private_ip,
    sfwp_user         = lookup(var.aws_ami_user, var.jumphost_vm_os),
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/hosts_aws"
  file_permission      = "0660"
  directory_permission = "0770"
}

# Generates the Ansible Config file (credentials)
resource "local_file" "ansible-config-infra" {
  content = templatefile("${path.module}/ansible_config.tmpl", {
    #ssh_priv_key_file = local.ssh_priv_key_file,
    ssh_priv_key_file = var.ssh_private_key_file,
    //    jumphost_user     = var.jumphost_admin_username,
    //    sfs_user          = var.sfs_admin_username,
    //    sfwp_user           = var.sfwp_admin_username,
    jumphost_user = lookup(var.aws_ami_user, var.jumphost_vm_os),
    jumphost_host = aws_instance.jumphost[0].public_ip,
    sfs_user      = lookup(var.aws_ami_user, var.jumphost_vm_os),
//        sfwp_user           = lookup(var.aws_ami_user, var.jumphost_vm_os),
    sfwp_user         = var.sfwp_admin_username,
    sfwp_password     = var.sfwp_admin_password,
    db_host           = local.db_address,
    db_admin_user     = var.spotfire_db_admin_username,
    db_admin_password = var.spotfire_db_admin_password,
    db_name           = var.spotfire_db_name,
    ui_admin_user     = var.spotfire_ui_admin_username,
    ui_admin_password = var.spotfire_ui_admin_password
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/infra.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}
