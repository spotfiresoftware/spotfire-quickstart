# Note: In AWS ECR, you can have only have one repository per image but each repository can have multiple versions (tags) of a single image.
# Therefore, we need to create a different ECR for each container image

variable "container_images" {
  default = [
    "tibco/spotfire-config",
    "tibco/spotfire-pythonservice",
    "tibco/spotfire-terrservice",
    "tibco/spotfire-automationservices",
    "tibco/spotfire-deployment",
    "tibco/spotfire-rservice",
    "tibco/spotfire-webplayer",
    "tibco/spotfire-base",
    "tibco/spotfire-node-manager",
    "tibco/spotfire-server",
    "tibco/spotfire-workerhost"
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