# --------------------------------------------------------------------
# Simple Terraform+Ansible Makefile.
# --------------------------------------------------------------------

# Change Makefile default shell is /bin/sh which does not implement source
#SHELL := /bin/bash

# import terraform.env vars
# You can change the default config with `make cfg="terraform.env" build`
cfg ?= ./terraform.env
include $(cfg)
#export $(bash sed 's/=.*//' $(cfg))
#$(shell mkdir -p $(shell dirname ${TF_LOG_PATH}))

# verify your system if you see 'pwd_unknown' showing up
PWD ?= pwd_unknown

## export any other extra variables
#MY_VARIABLE=my_value

# all our targets are phony (no files to check)
.PHONY: help init plan apply destroy reapply deploy

#### generic #####
help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

show-myip: ## Show my ip address
	dig +short myip.opendns.com @resolver1.opendns.com

#### common terraform #####
lint: ## Validate the Terraform configuration files
	terraform validate

format: ## Format the Terraform configuration files
	terraform fmt

init: ## Initialize the Terraform working directory. Required to apply new modules or provider upgrades.
	terraform init --upgrade

plan: ## Generate and show the Terraform execution plan
	terraform plan

apply: ## Build or change the Terraform managed infrastructure
	time terraform apply --auto-approve

destroy: ## Destroy the Terraform managed infrastructure
	time terraform destroy --auto-approve

reapply: destroy apply

terraform-graph:
	terraform graph | dot -Tsvg > terraform.tfstate.d/terraform_graph.svg
	terraform graph -draw-cycles | dot -Tsvg > terraform.tfstate.d/terraform_graph_cycles.svg

#### AWS specific #####
aws-login: ## login into AWS using AWS cli
	# aws configure
	# source <(aws sts assume-role --role-arn arn:aws:iam::987537861642:role/SpotfirePowerUser --profile SpotfirePMRole --role-session-name SpotfirePowerUser | jq -r  '.Credentials | @sh "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n "')
	@aws sts assume-role --role-arn arn:aws:iam::987537861642:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_use_f578f20054c0baf1 --profile SpotfirePMuse --role-session-name SpotfirePMuse \
		| jq -r  '.Credentials | "\nSet the following variables in your environment:\n\nexport AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n"'

aws-create-eks-roles: ## Create the needed EKS cluster and node roles, and attach IAM managed policies
	./create-AmazonEKSClusterRole.sh
	./create-AmazonEKSNodeRole.sh

aws-eks-cfg-kubectl: ## Retrieve the access credentials for your cluster and automatically configure kubectl
	aws eks --region $(shell terraform output -raw region) update-kubeconfig --name $(shell terraform output -raw cluster_name)
	#aws eks update-kubeconfig --name $(shell terraform output -raw cluster_name)  --profile use-987537861642 --role-arn arn:aws:iam::987537861642:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_use_f578f20054c0baf1

aws-eks-show: ## Show your cluster
	aws eks describe-cluster --name $(shell terraform output -raw cluster_name)

#### Azure specific (OCI registry) #####
aws-ecr-show: ## Show your OCI registry
	$(eval REGISTRY=$(shell aws sts get-caller-identity | jq -r ".Account").dkr.ecr.$(shell terraform output -raw region).amazonaws.com)
	@echo -n "To set your REGISTRY, run:\nexport REGISTRY=$(REGISTRY)\n\n"

aws-ecr-login: ## Log in to ECR (Amazon Elastic Container Registry)
	aws ecr get-login-password --region $(shell terraform output -raw region) | docker login --username AWS --password-stdin $(shell aws sts get-caller-identity | jq -r ".Account").dkr.ecr.$(shell terraform output -raw region).amazonaws.com
