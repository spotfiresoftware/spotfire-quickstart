# --------------------------------------------------------------------
# Simple Spotfire CDK CI/CD pipeline automation
# --------------------------------------------------------------------

# This Makefile is an example for easier reference and smother quickstart.
#
# For modifying this Makefile to an specific Spotfire CDK release, see:
# https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main

# import terraform.env vars
# You can change the default config with `make cfg="terraform.env" build`
cfg ?= ./variables.env
include $(cfg)

.DEFAULT_GOAL := help

#### generic #####
help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

#### common Terraform #####
git-clone-spotfire-cdk: ## Clone or update the Spotfire CDK repository
	mkdir -p build \
	  && cd build \
	  && git clone https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/ 2>/dev/null || (cd $(SPOTFIRE_CDK_REPO_DIR) ; git pull)

docker-build-images: ## Build Spotfire container images with Spotfire CDK
	cd $(SPOTFIRE_CDK_REPO_DIR)/containers \
	  && time make \
	  	IMAGE_BUILD_ID=$(IMAGE_BUILD_ID) \
	  	DOWNLOADS_DIR=$(DOWNLOADS_DIR) \
	  	DOCKER_CLI_BUILD_ARGS="--network=host" \
	  	build

docker-push-images: ## Push Spotfire container images to the registry $REGISTRY
	cd $(SPOTFIRE_CDK_REPO_DIR)/containers \
	  && time make \
	  	REGISTRY=$(REGISTRY) \
		IMAGE_BUILD_ID=$(IMAGE_BUILD_ID) \
		push

helm-pkg-spotfire: ## Package Spotfire Helm charts
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm \
	  && time make

helm-deploy-spotfire: ## Deploy Spotfire using custom Helm umbrella chart
	kubectl create namespace $(NAMESPACE) || true
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm/ \
       && time helm upgrade --install --namespace $(NAMESPACE) $(RELEASE)-spotty examples/spotfire-umbrella-example \
         --set global.spotfire.acceptEUA=true \
         --set global.spotfire.image.registry=$(REGISTRY) \
         --set global.spotfire.image.pullPolicy="Always" \
         --set spotfire-server.haproxy.service.type="LoadBalancer" \
         -f examples/spotfire-umbrella-example/values-initial-setup.yaml \
         -f examples/spotfire-umbrella-example/values-multiple-services-and-webplayer-pools.yaml

helm-ls-namespace: ## Show deployed Helm charts in configured namespace
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm \
	  && time helm --namespace $(NAMESPACE) ls

kubectl-ls-namespace: ## Show deployed Helm charts in configured namespace
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm \
	  && time kubectl --namespace $(NAMESPACE) get all

kubectl-terminate-pods: ## Show deployed Helm charts in configured namespace
	for p in $(kubectl -n $(NAMESPACE) get pods | grep Terminating | awk '{print $1}'); do kubectl delete pod $p --grace-period=0 --force;done


show-spotfire-credentials: ## Show the automatically generated Spotfire admin password
	$(eval SPOTFIREADMIN_PASSWORD=$(shell kubectl get secrets --namespace $(NAMESPACE) $(RELEASE)-spotty-spotfire-server -o jsonpath="{.data.SPOTFIREADMIN_PASSWORD}" | base64 --decode))
	@echo "SPOTFIREADMIN_PASSWORD=$(SPOTFIREADMIN_PASSWORD)"

#show-spotfire-lb:
#	$(eval LB_IP_ADDRESS=kubectl --namespace $(NAMESPACE) get service/$(RELEASE)-spotty-haproxy --output json  | jq -r '.status[].ingress[].ip' )

show-namespace: helm-ls-namespace kubectl-ls-namespace
docker-build-push-images: git-clone-spotfire-cdk docker-build-images docker-push-images ## Build and push the Spotfire container images to the configured OCI registry
helm-pkg-deploy-charts: helm-pkg-spotfire helm-deploy-spotfire show-spotfire-credentials ## Package Spotfire Helm charts and deploy Spotfire to the default configured K8s cluster in kubectl
all: docker-build-push-images helm-pkg-deploy-charts show-spotfire-credentials ## All in one command