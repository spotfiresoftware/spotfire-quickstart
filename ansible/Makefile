# --------------------------------------------------------------------
# Simple Ansible Makefile
# --------------------------------------------------------------------

# import config.env vars.
# You can change the default config with `make cfg="config_special.env" build`
#cfg ?= ../config.env
#include $(cfg)
#export $(bash sed 's/=.*//' $(cfg))

# verify your system if you see 'pwd_unknown' showing up.
PWD ?= pwd_unknown

## export what needs to be passed to shell functions for Docker to pick up.
#SPOTFIRE_DB_TYPE=postgres
#

# all our targets are phony (no files to check).
.PHONY: help lint fetch deploy

#### generic #####

help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help

lint: ## verify ansible syntax (using ansible-lint)
	#https://docs.ansible.com/ansible-lint
	pip3 install ansible-lint
	ansible-lint site.yml

#clean: ## empty build folder
#	rm -rf build/*

deploy: ## idempotent deploy software into existing infrastructure
	ANSIBLE_DISPLAY_SKIPPED_HOSTS=false ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
		ansible-playbook \
		-i inventory/host_groups_azure_rm.yml \
		--extra-vars @config/vars.yml \
		site.yml
		# --limit sfwp_servers
