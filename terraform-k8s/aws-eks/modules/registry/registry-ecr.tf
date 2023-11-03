variable "container_image" {
  default = ""
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository

# Note: In AWS ECR, you can have only have one repository per image but each repository can have multiple versions (tags) of a single image.
# Therefore, we need to create a different ECR for each container image

#variable "prefix" {
#  default = ""
#}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "this" {
  #name                 = "${var.prefix}-reg"
  name                 = var.container_image

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
variable "registry_principal_ids" {
  default = ""
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "new policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      #identifiers = ["123456789012"]
      #identifiers = ["*"]
      identifiers =  var.registry_principal_ids
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
resource "aws_ecr_repository_policy" "this" {
  #repository = aws_ecr_repository.this.name
  repository = var.container_image

  policy     = data.aws_iam_policy_document.this.json

  depends_on = [
    aws_ecr_repository.this
  ]
}

#output "registry_address" {
#  description = "Registry address"
#  value       = aws_ecr_repository.this.repository_url
#}