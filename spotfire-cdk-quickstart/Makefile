# --------------------------------------------------------------------
# Simple Spotfire CDK CI/CD pipeline automation
# --------------------------------------------------------------------

# This Makefile is an example for easier reference and smother quickstart.
#
# For modifying this Makefile to an specific Spotfire CDK release, see:
# https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit

# import variables.env vars
cfg ?= ./variables.env
include $(cfg)
include ./build/spotfire-cloud-deployment-kit/versions.mk

.DEFAULT_GOAL := help

#### generic #####
help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

#### CDK clone #####

git-clone-spotfire-cdk: ## Clone or update the Spotfire CDK repository
	mkdir -p build \
	  && cd build \
	  && git clone https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/ 2>/dev/null || (cd $(SPOTFIRE_CDK_REPO_DIR) ; git checkout main; git pull)

#### CDK build #####

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
	  	CONTAINER_REGISTRY=$(REGISTRY_SERVER) \
		IMAGE_BUILD_ID=$(IMAGE_BUILD_ID) \
		push

helm-pkg-spotfire: ## Package Spotfire Helm charts
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm \
	  && time make

helm-push-charts: ## Push Spotfire Helm charts to the OCI registry $REGISTRY_SERVER
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm \
	  && time make \
	  	HELM_OCI_REGISTRY=oci://$(REGISTRY_SERVER)/charts \
		push

#### CDK deploy #####
helm-deploy-spotfire: ## Deploy Spotfire using CDK (self-built container images and Helm charts)
	kubectl create namespace $(NAMESPACE) || true
	cd $(SPOTFIRE_CDK_REPO_DIR)/helm/ \
      && time helm upgrade --install $(RELEASE) \
      	./packages/spotfire-platform-$(SPOTFIRE_PLATFORM_CHART_VERSION).tgz \
        --version $(SPOTFIRE_PLATFORM_CHART_VERSION) \
        --namespace=$(NAMESPACE) \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$(REGISTRY_SERVER) \
        --set global.spotfire.image.pullPolicy="Always" \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        --set spotfire-server.haproxy.service.type="LoadBalancer" \
        --set spotfire-server.configJob.logLevel=INFO \
        --set spotfire-server.cliPod.enabled=false \
        --set postgresql.enabled=true \
        --set postgresql.primary.resourcesPreset=small \
        --set postgresql.primary.persistence.enabled=true \
        --render-subchart-notes

#        -f $(SPOTFIRE_CDK_REPO_DIR)/user-guide/examples/umbrella-values/values-initial-setup.yaml \
#        -f $(SPOTFIRE_CDK_REPO_DIR)/user-guide/examples/umbrella-values/values-multiple-services.yaml \

# NOTE: To apply always configuration
#       --set spotfire-server.configuration.apply=always \

# NOTE: If you want to use a custom Postgres image version, you can use for example:
#       Observe pinned postgres version	17.6.0 and using bitnamilegacy/postgresql due to recent changes in the official postgres image licensing.
#        --set postgresql.image.tag=17.6.0 \
#        --set postgresql.image.repository=bitnamilegacy/postgresql \
#        --set postgresql.image.debug=true \

docker-build-push-images: git-clone-spotfire-cdk docker-build-images docker-push-images # Clone/pull Spotfire CDK repo AND build Spotfire images AND push Spotfire images to the configured OCI registry
helm-pkg-deploy-charts: helm-pkg-spotfire helm-deploy-spotfire show-spotfire-credentials # Package Spotfire Helm charts AND deploy Spotfire to the default configured K8s cluster in kubectl
all: docker-build-push-images helm-pkg-deploy-charts show-namespace show-spotfire-credentials show-lb verify-lb ## All in one command

#### common gists #####

helm-ns-delete-release: ## Show deployed Helm charts in configured namespace
	helm --namespace $(NAMESPACE) delete $(RELEASE) || true
	kubectl delete -n $(NAMESPACE) pvc data-$(RELEASE)-postgresql-0 || true

helm-ns-ls: ## Show deployed Helm charts in configured namespace
	helm --namespace $(NAMESPACE) ls

kubectl-delete-namespace: ## Delete configured namespace
	kubectl delete namespace $(NAMESPACE) || true

kubectl-ns-get-all: ## Show all objects in configured namespace
	kubectl --namespace $(NAMESPACE) get all

kubectl-ns-terminate-pods: ## Kill all "terminating" pods in configured namespace
	$(shell kubectl -n $(NAMESPACE) get pods | grep Terminating | awk '{print $1}' | xargs kubectl -n $(NAMESPACE) delete pod $p --grace-period=0 --force)

show-spotfire-admin-credentials: ## Show the automatically generated Spotfire admin password
	$(eval SPOTFIREADMIN_PASSWORD=$(shell kubectl get secrets --namespace $(NAMESPACE) $(RELEASE)-spotfire-server -o jsonpath="{.data.SPOTFIREADMIN_PASSWORD}" | base64 --decode))
	@echo "SPOTFIREADMIN_PASSWORD=$(SPOTFIREADMIN_PASSWORD)"

show-lb: ## Show Load Balancer IP/hostname
#	$(eval SPOTFIRE_LB_PIP=$(shell kubectl --namespace $(NAMESPACE) get service/$(RELEASE)-haproxy -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval SPOTFIRE_LB_PIP=$(shell kubectl --namespace $(NAMESPACE) get svc $(RELEASE)-haproxy -o json | jq -r '.status.loadBalancer.ingress[0] | if .ip then .ip else .hostname end'))
	@echo "SPOTFIRE_LB_PIP=http://$(SPOTFIRE_LB_PIP)"

verify-lb: ## Verify connection to Spotfire via Load Balancer
#	$(eval SPOTFIRE_LB_PIP=$(shell kubectl --namespace $(NAMESPACE) get service/$(RELEASE)-haproxy -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	$(eval SPOTFIRE_LB_PIP=$(shell kubectl --namespace $(NAMESPACE) get svc $(RELEASE)-haproxy -o json | jq -r '.status.loadBalancer.ingress[0] | if .ip then .ip else .hostname end'))
	@echo "[INFO] Verify Spotfire response from: $(SPOTFIRE_LB_PIP) ..."
	curl $(SPOTFIRE_LB_PIP) -v -H "Host: spotfire.local" -L

prune-ns: helm-ns-delete-release kubectl-ns-terminate-pods kubectl-delete-namespace kubectl-ns-get-all ## Delete the release and prune the namespace

deploy-release: kubectl-ns-create-oci-registry-secret helm-deploy-spotfire show-spotfire-admin-credentials kubectl-ns-get-all ## Prepare the namespace and deploy release
