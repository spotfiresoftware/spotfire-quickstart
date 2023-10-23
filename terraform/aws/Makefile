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
#INVENTORY_FILE=../terraform/aws/config/${TF_WORKSPACE}/hosts
#INVENTORY_FILE=../terraform/aws/config/${TF_WORKSPACE}/host_groups_aws_ec2.yml
#INVENTORY_FILE=../terraform/aws/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/host_groups_aws_ec2.yml
# NOTE: Dynamic inventory with aws_ec2 is tricky when using jumphost. I prefer to use a plain inventory file from a template
#INVENTORY_FILE=../terraform/aws/hosts_aws # you can use hosts_aws.example as starting point
INVENTORY_FILE=../terraform/aws/terraform.tfstate.d/spotfire-aws-dev/ansible_config/hosts_aws
export INVENTORY_FILE

# ansible environment configuration
INFRA_EXTRA_VARS=@../terraform/aws/terraform.tfstate.d/${TF_WORKSPACE}/ansible_config/infra.yml
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
	time terraform destroy --auto-approve

reapply: destroy apply

terraform-graph:
	terraform graph | dot -Tsvg > terraform.tfstate.d/terraform_graph.svg
	terraform graph -draw-cycles | dot -Tsvg > terraform.tfstate.d/terraform_graph_cycles.svg

#### specific AWS #####
show-hosts: ## List hosts inventory (sw deployment targets) using AWS cli
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
	@echo "Name\t\tPrivateIpAddres\tPublicIpAddress\tPublicDnsName"
	@echo "---------------\t---------------\t---------------\t---------------"
	@aws ec2 describe-instances  \
		--query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PrivateIpAddress, PublicIpAddress, PublicDnsName]" \
		--output=text \
		--filters Name=instance-state-name,Values=running \
		| sort -k1

show-lb: ## List Load Balancer using AWS cli
# https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-load-balancers.html?highlight=elbv2
	@echo "LoadBalancerName\tDNSName"
	@aws elbv2 describe-load-balancers --query "LoadBalancers[*].[LoadBalancerName, DNSName]" --output=text

verify-lb: ## Verify connection to Spotfire via Load Balancer (AWS ELB) IP address
	$(eval SPOTFIRE_LB_PIP=$(shell aws elbv2 describe-load-balancers --query "LoadBalancers[*].DNSName" --output=text))
	echo $(SPOTFIRE_LB_PIP)
	curl $(SPOTFIRE_LB_PIP) -v -H "Host: spotfire.local" -L

show-myip: ## Show my ip address
	dig +short myip.opendns.com @resolver1.opendns.com

#### common Ansible #####
show-inventory: ## List hosts inventory (sw deployment targets) using Ansible (short)
	cd ../../ansible && \
		ansible-inventory \
		    -i ${INVENTORY_FILE} \
			--graph

show-inventory-list: ## List hosts inventory (sw deployment targets) using Ansible (long)
	cd ../../ansible && \
		ansible-inventory \
		    -i ${INVENTORY_FILE} \
			--list

show-os: ## List hosts distributions (sw deployment targets) using Ansible facts
	cd ../../ansible && \
		#ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=120" \
		#ANSIBLE_SSH_ARGS=" -F ../terraform/aws/ssh-aws.cfg -o ForwardX11=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=120" \
		ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_STDOUT_CALLBACK=yaml ANSIBLE_STDOUT_CALLBACK=debug \
		ansible \
		    -i ${INVENTORY_FILE} \
		 	--extra-vars ${INFRA_EXTRA_VARS} \
			all -m ansible.builtin.setup \
			$(ANSIBLE_EXTRA_ARGS) \
			-a "filter=ansible_distribution*"

show-facts: ## Show hosts inventory facts using Ansible facts
	cd ../../ansible && \
		ANSIBLE_HOST_KEY_CHECKING=False ansible \
		    -i ${INVENTORY_FILE} \
		 	--extra-vars ${INFRA_EXTRA_VARS} \
			all -m ansible.builtin.setup \
	  		$(ANSIBLE_EXTRA_ARGS) \
			--tree build/facts

debug:
	cd ../../ansible && \
		ansible-playbook \
		    -i ${INVENTORY_FILE} \
			--extra-vars @config/vars.yml \
		 	--extra-vars ${INFRA_EXTRA_VARS} \
			all -m ansible.builtin.setup \
	  		$(ANSIBLE_EXTRA_ARGS) \
			site_debug.yml

deploy: ## Install and configure Spotfire software on infra hosts using Ansible playbooks
	cd ../../ansible && \
#		export ANSIBLE_CONFIG=./ansible.cfg && \
#		ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=120" \
		#ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=120 ANSIBLE_TIMEOUT=120 ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False \
		ansible-playbook \
			-i ${INVENTORY_FILE} \
			--extra-vars @config/vars.yml \
			--extra-vars ${INFRA_EXTRA_VARS} \
			$(ANSIBLE_EXTRA_ARGS) \
			site.yml
#  			--limit sfwp_servers \
#	  		 -vvv

#### other AWS specific #####
aws-assume-role-env: ## Fetch assume role info for AWS cli
	# aws configure
# source <(aws sts assume-role --role-arn arn:aws:iam::987537861642:role/SpotfirePowerUser --profile SpotfirePMRole --role-session-name SpotfirePowerUser | jq -r  '.Credentials | @sh "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n "')
	@aws sts assume-role --role-arn arn:aws:iam::987537861642:role/SpotfirePowerUser --profile SpotfirePMRole --role-session-name SpotfirePowerUser \
		| jq -r  '.Credentials | "\nSet the following variables in your environment:\n\nexport AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n"'
