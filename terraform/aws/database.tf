#----------------------------------------
# Relational Database Server
# (with AWS RDS for PostgreSQL)
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
# https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws
#
# TODO: Use AWS Module for RDS: https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
# TODO: Use SSL: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.Security.html
#----------------------------------------

# Create a data source for the availability zones.
data "aws_availability_zones" "available" {
}

resource "aws_subnet" "rds" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.prefix}-spotfire-rds-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "this" {
  name        = "${var.prefix}-spotfire-db-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = aws_subnet.rds.*.id
}

resource "aws_security_group" "rds" {
  name        = "${var.prefix}-spotfire-db-sg"
  description = "RDS security group"
  vpc_id      = aws_vpc.this.id

  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
    aws_security_group.tss-web.id]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-spotfire-db-sg"
  }
}

locals {
  db_instance_id = "${var.prefix}-spotfire-db"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "this" {
  // conditional module execution
  count = var.create_spotfire_db ? 1 : 0

  identifier = local.db_instance_id

  allocated_storage      = var.spotfire_db_size
  db_name                = var.spotfire_db_name
  engine                 = "postgres"
  engine_version         = var.postgresql_db_version
  instance_class         = var.spotfire_db_instance_class
  username               = var.spotfire_db_admin_username
  password               = var.spotfire_db_admin_password
  db_subnet_group_name   = aws_db_subnet_group.this.id
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible       = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html
resource "aws_db_parameter_group" "this" {
  name        = "${var.prefix}-spotfire-db-param-group"
  description = "RDS parameter group"
  family      = "postgres13"
}