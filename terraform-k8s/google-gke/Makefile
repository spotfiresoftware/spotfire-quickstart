# --------------------------------------------------------------------
# Simple Terraform Makefile.
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

#### GCP specific #####
gcp-login: ## Login into GCP using gcloud (Google Cloud cli)
	gcloud auth application-default login # for authentication with user credentials

gcp-enable-apis: ## Enable required GCP service APIs
	gcloud services enable container.googleapis.com
	gcloud services enable containerregistry.googleapis.com
	gcloud services enable containerscanning.googleapis.com

gcp-gke-login: ## Get GCP GKE and Artifact Registry credentials
	gcloud container clusters get-credentials $(shell terraform output -raw kubernetes_cluster_name) --region $(shell terraform output -raw region)
	gcloud auth configure-docker $(shell terraform output -raw region)-docker.pkg.dev

gcp-gke-show: ## Show your cluster
	gcloud container clusters describe $(shell terraform output -raw kubernetes_cluster_name) --region $(shell terraform output -raw region)

gcp-gke-cfg-kubectl: ## Retrieve the access credentials for your cluster and automatically configure kubectl
	# https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl
	gcloud container clusters get-credentials $(shell terraform output -raw kubernetes_cluster_name) --region $(shell terraform output -raw region)

#### Google specific (OCI registry) #####
gcp-registry-show: ## Show your OCI registry
	$(eval REGISTRY=$(shell terraform output -raw google_artifact_registry_repository))
	@echo -n "To set your REGISTRY, run:\nexport REGISTRY=$(REGISTRY)\n\n"

#### k8s common #####
k8s-deploy-dashboard: ## Deploy the Kubernetes dashboard
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
	kubectl proxy &

k8s-get-token: ## create ClusterRoleBinding resource and generate the authorization token to access the k8s dashboard
	kubectl apply -f kubernetes-dashboard-admin.rbac.yaml
	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')

k8s-info: ## show k8s cluster-info
	kubectl cluster-info
