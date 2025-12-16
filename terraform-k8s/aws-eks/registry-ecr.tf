# Note: In AWS ECR, you can have only have one repository per image but each repository can have multiple versions (tags) of a single image.
# Therefore, we need to create a different ECR for each container image

variable "container_images" {
  default = [
    "spotfire/spotfire-base",
    "spotfire/spotfire-config",
    "spotfire/spotfire-server",
    "spotfire/spotfire-nodemanager",
    "spotfire/spotfire-workerhost",
    "spotfire/spotfire-webplayer",
    "spotfire/spotfire-automationservices",
    "spotfire/spotfire-deployment",
    "spotfire/spotfire-pythonservice",
    "spotfire/spotfire-rservice",
    "spotfire/spotfire-terrservice"
  ]
  description = "Spotfire container images"
}

## Setup networking
variable "create_registry" {
  description = "Whether to create the Azure Container Registry"
  type        = bool
  default     = true
}

module "registry" {
  source = "./modules/registry"
  #  location = var.location
  #  prefix   = var.prefix
  #  tags     = var.tags

  # loop through the list (if create_registy = true)
  for_each        = var.create_registry ? toset(var.container_images) : []
  container_image = each.key

  registry_principal_ids = [var.iam_eks_cluster_role_arn]
}

#output "registry_address" {
#  description = "Registry address"
#  value       = module.registry.registry_address
#}