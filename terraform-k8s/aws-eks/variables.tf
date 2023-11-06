#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "prefix" {
  default     = "k8s-codename"
  description = "Prefix for resources"
}

#----------------------------------------
# AWS Location: region
#----------------------------------------
# location
variable "region" {
  default     = "eu-north-1"
  description = "AWS region"
}

#----------------------------------------
# Networking
#----------------------------------------
variable "admin_address_prefixes" {
  # Recommended to use more strict than /9 mask
  description = "CIDR or source IP range allowed for environment administration"
  default     = ["43.21.0.0/16"]
}

#variable "vnet_address_space" {
#  description = "Virtual Network address space"
#  default     = "10.0.0.0/8"
#}

#----------------------------------------
# Kubernetes
#----------------------------------------
variable "eks_cluster_version" {
  default = "1.28"
  description = "EKS cluster version"
}

variable "eks_num_nodes" {
  default     = 2
  description = "Number of EKS nodes (per region)"
}

variable "eks_instance_type" {
  default     = [ "t3.xlarge" ]
  description = "Type of machine for k8s EKS nodes"
}

# iam_eks_cluster_role_arn
variable "iam_eks_cluster_role_arn" {
  default     = "arn:aws:iam::111122223333:role/EKSClusterRole"
  description = "Existing IAM role ARN for the EKS cluster"
}

# iam_eks_node_role_arn
variable "iam_eks_node_role_arn" {
  default     = "arn:aws:iam::111122223333:role/EKSNodeRole"
  description = "Existing IAM role ARN for the EKS nodes"
}

variable "eks_cluster_service_cidr_block" {
  default     = "172.20.0.0/16"
  description = "EKS cidr block"
}

# https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
variable "cluster_endpoint_private_access" {
  default = "true"
}

variable "cluster_endpoint_public_access" {
  default = "true"
}
