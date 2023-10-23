# --------------------------------------------------------------------
# Simple Terraform+Ansible Makefile.
# --------------------------------------------------------------------

# Change Makefile default shell is /bin/sh which does not implement source
#SHELL := /bin/bash

# Experimental: Get SPOTFIRE_PREFIX from configuration. Used for awareness to avoid own collisions.
SPOTFIRE_PREFIX=$(shell grep ^prefix *.tfvars | tail -1 | sed "s/[ \"]//g" | cut -d'=' -f2)
export SPOTFIRE_RG=${SPOTFIRE_PREFIX}-spotfire-rg
export SPOTFIRE_APPGW=${SPOTFIRE_PREFIX}-spotfire-appgw

$(info > Prefix: ${SPOTFIRE_PREFIX})
$(info > Resource Group: ${SPOTFIRE_RG})
$(info )

ifndef SPOTFIRE_PREFIX
  $(warning Variable SPOTFIRE_PREFIX may not be defined. Verify configuration)
endif

# import terraform.env vars
# You can change the default config with `make cfg="terraform.env" build`
cfg ?= ./terraform.env
include $(cfg)
export $(bash sed 's/=.*//' $(cfg))
$(shell mkdir -p $(shell dirname ${TF_LOG_PATH}))

# verify your system if you see 'pwd_unknown' showing up
PWD ?= pwd_unknown

## export any other extra variables
#MY_VARIABLE=my_value

# predefined Spotfire environment size
SPOTFIRE_SIZE=XS
export SPOTFIRE_SIZE

# ansible inventory file location
#INVENTORY_FILE=../terraform/gcp/hosts
INVENTORY_FILE=../terraform/gcp/host_groups_gcp.yml
INVENTORY_FILE_GOG=../terraform/gcp/host_groups_of_groups.yml
export INVENTORY_FILE

# ansible environment configuration
INFRA_EXTRA_VARS=@../terraform/gcp/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/infra.yml
export INFRA_EXTRA_VARS

# all our targets are phony (no files to check)
.PHONY: help init plan apply destroy reapply deploy

#### generic #####
help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help

#### common Terraform #####
lint: ## Validate the Terraform configuration files in a directory
	terraform validate

init: ## Initialize a Terraform working directory. Required to apply new modules or provider upgrades.
	terraform init --upgrade

plan: ## Generate and show the Terraform execution plan
	terraform plan -var-file="variables.tfvars" -var-file="vars-size-${SPOTFIRE_SIZE}.tfvars"

apply: ## Build or change the Terraform managed infrastructure
	time terraform apply -var-file="variables.tfvars" -var-file="vars-size-${SPOTFIRE_SIZE}.tfvars" --auto-approve

destroy: ## Destroy the Terraform managed infrastructure
	time terraform destroy -var-file="variables.tfvars" --auto-approve

reapply: destroy apply

infra: init plan apply ## init plan & apply

terraform-graph:
	terraform graph | dot -Tsvg > terraform.tfstate.d/terraform_graph.svg
	terraform graph -draw-cycles | dot -Tsvg > terraform.tfstate.d/terraform_graph_cycles.svg

#### specific Google Cloud #####
show-hosts: ## List hosts inventory (sw deployment targets) using GCP cli
	gcloud compute instances list

show-lb: ## List Load Balancer using GCP cli
	# https://cloud.google.com/sdk/gcloud/reference/compute/forwarding-rules
	gcloud compute forwarding-rules list

verify-lb: ## Verify connection to Spotfire via Load Balancer (Google Cloud Load Balancing) IP address
	$(eval SPOTFIRE_LB_PIP=$(shell gcloud compute forwarding-rules list --format json | jq -r .[].IPAddress))
	curl $(SPOTFIRE_LB_PIP) -v -H "Host: spotfire.local" -L
	@exit $$? # return exit code

show-myip: ## Show my ip address
	dig +short myip.opendns.com @resolver1.opendns.com

#### common Ansible #####
show-inventory: ## List hosts inventory (sw deployment targets) using Ansible (short)
	cd ../../ansible && \
		ansible-inventory \
		    -i ${INVENTORY_FILE} \
		    -i ${INVENTORY_FILE_GOG} \
			--graph

show-inventory-list: ## List hosts inventory (sw deployment targets) using Ansible (long)
	cd ../../ansible && \
		ansible-inventory \
		    -i ${INVENTORY_FILE} \
		    -i ${INVENTORY_FILE_GOG} \
			--list

show-os: ## List hosts distributions (sw deployment targets) using Ansible facts
	cd ../../ansible && \
		ANSIBLE_HOST_KEY_CHECKING=False ansible \
		    -i ${INVENTORY_FILE} \
   		    -i ${INVENTORY_FILE_GOG} \
		 	--extra-vars ${INFRA_EXTRA_VARS} \
			all -m ansible.builtin.setup \
			$(ANSIBLE_EXTRA_ARGS) \
			-a "filter=ansible_distribution*"

show-facts: ## Show hosts inventory facts using Ansible facts
	cd ../../ansible && \
		ANSIBLE_HOST_KEY_CHECKING=False ansible \
		    -i ${INVENTORY_FILE} \
		    -i ${INVENTORY_FILE_GOG} \
		 	--extra-vars ${INFRA_EXTRA_VARS} \
			all -m ansible.builtin.setup \
	  		$(ANSIBLE_EXTRA_ARGS) \
			--tree build/facts

deploy: ## Install and configure Spotfire software on infra hosts using Ansible playbooks
	cd ../../ansible && \
#		export ANSIBLE_CONFIG=./ansible.cfg && \
#		ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=120" \
		ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=120 ANSIBLE_TIMEOUT=120 ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False \
		ansible-playbook \
			-i ${INVENTORY_FILE} \
			-i ${INVENTORY_FILE_GOG} \
			--extra-vars @config/vars.yml \
			--extra-vars ${INFRA_EXTRA_VARS} \
			$(ANSIBLE_EXTRA_ARGS) \
			site.yml
#  			--limit sfwp_servers \
#	  		 -vvv

#### other GCP specific #####
gcp-login: ## Login into GCP using gcloud (Google Cloud cli)
	gcloud auth application-default login

gcp-enable-apis: ## Enable required GCP service APIs
	gcloud services enable containerregistry.googleapis.com
	gcloud services enable container.googleapis.com
