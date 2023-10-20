#----------------------------------------
# VPC
#
# TODO: Use AWS Module for VPC:
# - https://aws-quickstart.github.io/quickstart-aws-vpc/
# - https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.prefix}-spotfire-vpc"
  }
}

#----------------------------------------
# Subnets
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.prefix}-spotfire-public-${element(data.aws_availability_zones.available.names, count.index)}-subnet"
  }
}

resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.prefix}-spotfire-private-${element(data.aws_availability_zones.available.names, count.index)}-subnet"
  }
}

#----------------------------------------
# Internet Gateway
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.prefix}-spotfire-inetgw"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"                  # Defines default route
    gateway_id = aws_internet_gateway.this.id # via IGW
  }

  tags = {
    Name = "${var.prefix}-spotfire-route-public"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#----------------------------------------
# NAT Gateway
#----------------------------------------
# Elastic IPs
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "this" {
  count = length(data.aws_availability_zones.available.names)

  domain   = "vpc"
}

variable "single_nat_gateway" {
  default = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "this" {
  count = length(data.aws_availability_zones.available.names)

  allocation_id = element(aws_eip.this.*.id, var.single_nat_gateway ? 0 : count.index)
  subnet_id     = element(aws_subnet.public.*.id, var.single_nat_gateway ? 0 : count.index)

  tags = {
    Name = "${var.prefix}-spotfire-route-natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}

output "nat_gateway_ip" {
  value = aws_eip.this.*.public_ip
}

resource "aws_route_table" "private" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prefix}-spotfire-route-private"
  }
}

resource "aws_route" "private_nat_gateway" {
  count = length(data.aws_availability_zones.available.names)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
