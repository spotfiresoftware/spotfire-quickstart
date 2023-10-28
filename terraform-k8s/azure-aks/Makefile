# --------------------------------------------------------------------
# Simple Terraform Makefile.
# --------------------------------------------------------------------

# Change Makefile default shell (/bin/sh does not implement source)
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
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

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

#### Azure specific #####
az-login: ## Login into Azure using Azure cli
	az login --use-device-code

az-prepare: ## Prepare Azure AKS. Create AD Service Principal account
	./az_create_sp.sh

az-aks-cfg-kubectl: ## Retrieve the access credentials for your cluster and automatically configure kubectl
	az aks get-credentials --resource-group $(shell terraform output -raw resource_group_name) --name $(shell terraform output -raw kubernetes_cluster_name) --overwrite-existing

az-aks-show: ## Show your cluster
	az aks show --resource-group $(shell terraform output -raw resource_group_name) --name $(shell terraform output -raw kubernetes_cluster_name)

az-aks-show-dashboard: ## Show AKS dashboard url
	az aks browse --resource-group $(shell terraform output -raw resource_group_name) --name $(shell terraform output -raw kubernetes_cluster_name)

#### Azure specific (OCI registry) #####
az-registry-show: ## Show your OCI registry
	$(eval REGISTRY=$(shell terraform output -raw registry_url))
	@echo -n "To set your REGISTRY, run:\nexport REGISTRY=$(REGISTRY)\n\n"

az-acr-list: ## Show ACR (Azure Container Registry) list
	az acr list --resource-group $(shell terraform output -raw resource_group_name) --output table
	$(eval REGISTRY_NAME=$(shell terraform output -raw registry_name))
	az acr repository list --name $(REGISTRY_NAME) --output table
	az acr repository show-tags --name $(REGISTRY_NAME) --output table --repository tibco/spotfire-server

az-acr-login: ## Log in to ACR (Azure Container Registry)
	az acr login --name $(shell az acr list --resource-group $(shell terraform output -raw resource_group_name) --query "[].[loginServer]" --output tsv)

az-acr-verify: ## Verify ACR (Azure Container Registry) connectivity
	$(eval REGISTRY_NAME=$(shell terraform output -raw registry_name))
	# https://aka.ms/acr/health-check
	@echo -n "\nHealth check"
	az acr check-health --name $(REGISTRY_NAME) --vnet sandbox-peach-vnet -y
	# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/cannot-pull-image-from-acr-to-aks-cluster
	@echo -n "\nCheck ACR"
	az aks check-acr --name $(shell terraform output -raw kubernetes_cluster_name) --resource-group $(shell terraform output -raw resource_group_name) --acr $(REGISTRY_NAME)
	#az role assignment list --scope /subscriptions/<subscriptionID>/resourceGroups/$(shell terraform output -raw resource_group_name)/providers/Microsoft.ContainerRegistry/registries/$(REGISTRY_NAME) -o table
	#@echo -n "\nRoles"
	#$(eval ARM_SUBSCRIPTION_ID=00112233-4455-6677-8899-ABCDEFGHIJK)
	#az role assignment list --scope /subscriptions/$(ARM_SUBSCRIPTION_ID)/resourceGroups/$(shell terraform output -raw resource_group_name)/providers/Microsoft.ContainerRegistry/registries/$(REGISTRY_NAME) -o table

az-id:
	terraform output -raw arm_subscription_id
