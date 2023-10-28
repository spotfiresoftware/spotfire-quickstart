#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "tags" {
  type = map(string)

  default = {
    # specific tags
    description   = "Spotfire quickstart: basic install"
    app           = "Spotfire"
    app_version   = "12.5.0"
    environment   = "dev"
    infra_version = "0.3"
  }
}

variable "prefix" {
  default     = "k8s-codename"
  description = "Prefix for resources"
}

#----------------------------------------
# Azure location and region
#----------------------------------------
variable "location" {
  default     = "northeurope"
  description = "Azure location"
}

variable "region" {
  default     = "northeurope"
  description = "Azure region"
}

# credentials
variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}

#----------------------------------------
# Networking
#----------------------------------------
variable "admin_address_prefixes" {
  # Recommended to use more strict than /9 mask
  description = "CIDR or source IP range allowed for environment administration"
  default     = ["43.21.0.0/16"]
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  default     = "10.0.0.0/8"
}

variable "k8s_subnet_address_prefixes" {
  description = "AKS subnet address space"
  default     = ["10.10.0.0/24"]
}

variable "aks_service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs."
  default     = "10.10.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "AKS DNS server IP address."
  default     = "10.10.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "A CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "appgw_subnet_address_prefixes" {
  description = "Azure Application Gateway's SubNetwork address space"
  default     = ["10.10.1.0/24"]
}

#----------------------------------------
# Kubernetes
#----------------------------------------
variable "aks_cluster_version" {
  default = "1.28"
  description = "Kubernetes cluster version"
}

variable "aks_num_nodes" {
  default     = 3
  description = "Number of AKS nodes (per region)"
}

variable "aks_machine_type" {
  default     = "Standard_D2_v2"
  description = "Type of machine for AKS nodes"
}

variable "aks_machine_disk_size" {
  default = "30"
  description = "Disk size for AKS nodes"
}

variable "aks_service_principal_object_id" {
  default = ""
}