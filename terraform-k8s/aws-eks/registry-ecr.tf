# Note: In AWS ECR, you can have only have one repository per image but each repository can have multiple versions (tags) of a single image.
# Therefore, we need to create a different ECR for each container image

variable "container_images" {
  default = [
    "spotfire/spotfire-config",
    "spotfire/spotfire-pythonservice",
    "spotfire/spotfire-terrservice",
    "spotfire/spotfire-automationservices",
    "spotfire/spotfire-deployment",
    "spotfire/spotfire-rservice",
    "spotfire/spotfire-webplayer",
    "spotfire/spotfire-base",
    "spotfire/spotfire-nodemanager",
    "spotfire/spotfire-server",
    "spotfire/spotfire-workerhost"
  ]
  description = "Spotfire container images"
}

## Setup networking
module "registry" {
  source = "./modules/registry"
  #  location = var.location
  #  prefix   = var.prefix
  #  tags     = var.tags

  # loop through the list
  for_each        = toset(var.container_images)
  container_image = each.key

  registry_principal_ids = [var.iam_eks_cluster_role_arn]
}

#output "registry_address" {
#  description = "Registry address"
#  value       = module.registry.registry_address
#}