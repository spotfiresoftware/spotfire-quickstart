#variable "eks_subnet_list" {
#  default = ""
#}
#variable "cluster_endpoint_public_access_cidrs" {
#  default = ""
#}

###############################
# EKS cluster
###############################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.prefix}-cluster"
  role_arn = var.iam_eks_cluster_role_arn
  version = var.eks_cluster_version

  vpc_config {
    #subnet_ids = var.eks_subnet_list
    #subnet_ids = local.vpc_private_subnet_cidr_list
    subnet_ids = module.vpc.private_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs = var.admin_address_prefixes
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks_cluster_service_cidr_block
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    module.vpc
  ]
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#  depends_on = [
#    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
#    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
#  ]
}

#data "aws_iam_policy_document" "assume_role_eks_cluster_role" {
#  statement {
#    effect = "Allow"
#
#    principals {
#      type        = "Service"
#      identifiers = ["eks.amazonaws.com"]
#    }
#
#    actions = ["sts:AssumeRole"]
#  }
#}
#
#resource "aws_iam_role" "eks_cluster_role" {
#  name               = "eks-cluster-role"
#  assume_role_policy = data.aws_iam_policy_document.assume_role.json
#}
#
#resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#  role       = aws_iam_role.eks_cluster_role.name
#}
#
## Optionally, enable Security Groups for Pods
## Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
#resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#  role       = aws_iam_role.eks_cluster_role.name
#}

###############################
# EKS node group
###############################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "group-1"
  node_role_arn   = var.iam_eks_node_role_arn
  #subnet_ids      = local.vpc_private_subnet_cidr_list
  subnet_ids      = module.vpc.private_subnets
  instance_types       = var.eks_instance_type

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#  depends_on = [
#    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
#    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
#    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
#  ]
}

#resource "aws_iam_role" "eks_node_role" {
#  name = "eks_node_role"
#
#  assume_role_policy = jsonencode({
#    Statement = [{
#      Action = "sts:AssumeRole"
#      Effect = "Allow"
#      Principal = {
#        Service = "ec2.amazonaws.com"
#      }
#    }]
#    Version = "2012-10-17"
#  })
#}
#
#resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#  role       = aws_iam_role.eks_node_role.name
#}
#
#resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  role       = aws_iam_role.eks_node_role.name
#}
#
#resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#  role       = aws_iam_role.eks_node_role.name
#}

# Datasource: AWS Partition
# Use this data source to lookup information about the current AWS partition in which Terraform is working
#data "aws_partition" "current" {}
