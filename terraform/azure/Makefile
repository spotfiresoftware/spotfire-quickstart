# --------------------------------------------------------------------
# Simple Terraform+Ansible Makefile.
# --------------------------------------------------------------------

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

# all our targets are phony (no files to check)
.PHONY: help init plan apply destroy reapply deploy

#### generic #####
help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help

#### specific #####

azlogin: ## login into Azure using Azure cli
	az login

lint: ## Validate the Terraform configuration files in a directory
	terraform validate

init: ## Initialize a Terraform working directory. Required to apply new modules or provider upgrades.
	terraform init --upgrade

plan: ## Generate and show the Terraform execution plan
	terraform plan -var-file="variables.tfvars" -var-file="vars-size-${SPOTFIRE_SIZE}.tfvars"

apply: ## Build or change the Terraform managed infrastructure
	time terraform apply -var-file="variables.tfvars" -var-file="vars-size-${SPOTFIRE_SIZE}.tfvars" --auto-approve

destroy: ## Destroy the Terraform managed infrastructure
	time terraform destroy --auto-approve

reapply: destroy apply

show-hosts: ## List hosts inventory (sw deployment targets) using az cli
	$(eval SPOTFIRE_RG=$(shell grep ^prefix variables.tfvars | sed "s/[ \"]//g" | cut -d'=' -f2)-spotfire-rg)
	az vm list-ip-addresses --resource-group ${SPOTFIRE_RG} --output table

show-myip: ## Show my ip address
	dig +short myip.opendns.com @resolver1.opendns.com

show-inventory: ## List hosts inventory (sw deployment targets) using Ansible (short)
	cd ../../ansible && \
		ansible-inventory \
		    -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
			--graph

show-inventory-list: ## List hosts inventory (sw deployment targets) using Ansible (long)
	cd ../../ansible && \
		ansible-inventory \
		    -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
			--list

show-os: ## List hosts distributions (sw deployment targets) using Ansible facts
	cd ../../ansible && \
		ANSIBLE_HOST_KEY_CHECKING=False ansible \
		    -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
		 	--extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/infra.yml \
			all -m ansible.builtin.setup \
			-a "filter=ansible_distribution*"

show-facts: ## Show hosts inventory facts using Ansible facts
	cd ../../ansible && \
		ANSIBLE_HOST_KEY_CHECKING=False ansible \
			-i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
		 	--extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/infra.yml \
			all -m ansible.builtin.setup \
			--tree build/facts

deploy: ## Install and configure Spotfire software on infra hosts using Ansible playbooks
	cd ../../ansible && \
		ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
			ansible-playbook \
		    -i ../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_azure_rm.yml \
		 	--extra-vars @config/vars.yml \
		 	--extra-vars @../terraform/azure/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/infra.yml \
	  		site.yml
#  			--limit wp_servers \
#	  		 -vvv

terraform-graph:
	terraform graph | dot -Tsvg > terraform.tfstate.d/terraform_graph.svg
	terraform graph -draw-cycles | dot -Tsvg > terraform.tfstate.d/terraform_graph_cycles.svg
