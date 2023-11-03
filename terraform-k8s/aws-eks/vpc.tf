data "aws_availability_zones" "available" {}


locals {
  vpc_cidr = "10.0.0.0/16"
  vpc_public_subnet_cidr_list = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_private_subnet_cidr_list = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  vpc_database_subnet_cidr_list = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  eks_cluster_service_cidr_block = "172.20.0.0/16"
}

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
#  version = "~> 5.1.2"

  name            = "${var.prefix}-vpc"
  cidr            = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = local.vpc_private_subnet_cidr_list
  public_subnets  = local.vpc_public_subnet_cidr_list

  enable_nat_gateway   = true
  enable_vpn_gateway = true

  single_nat_gateway   = true
  enable_dns_hostnames = true
}

#module "eks" {
#  source  = "terraform-aws-modules/eks/aws"
#  //version = "19.15.3"
#
#  cluster_name    = "${var.prefix}-eks"
#  //cluster_version = "1.27"
#
#  vpc_id                         = module.vpc.vpc_id
#  subnet_ids                     = module.vpc.private_subnets
#  cluster_endpoint_public_access = true
#
#  eks_managed_node_group_defaults = {
#    ami_type = "AL2_x86_64"
#
#  }
#
#  eks_managed_node_groups = {
#    one = {
#      name = "node-group-1"
#
#      instance_types = ["t3.small"]
#
#      min_size     = 1
#      max_size     = 3
#      desired_size = 2
#    }
#
#  }
#}