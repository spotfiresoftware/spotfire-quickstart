# Deploy Spotfire on a kubernetes cluster using the Spotfire CDK

This `Makefile` provides an example for easier reference and smother quickstart for implementing a Spotfire CI/CD pipeline automation using the [Spotfire Cloud Deployment Kit (CDK)](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main).

For modifying this Makefile to a specific Spotfire CDK release, see: https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main

**Note**: If you prefer, you can just use the Spotfire CDK directly.
This is just a simple wrapper for easier quickstart.

## Prerequisites

- You have downloaded the Spotfire installation packaged and copied them into your launcher. See [Spotfire software repository](../../swrepo/build/README.md)
- You have set the variable `REGISTRY` pointing to your OCI registry.
- You have a working Kubernetes cluster, configured and validated with your kubectl
- You have the following installed command tools: `make`, `docker`, `kubectl`, `helm`.

## Procedure

Read and, if needed, configure the file [variables.env](./variables.env).

### Alternative 1: TL;DR

Just run:
```bash
make all
```

### Alternative 2: Step by step

If this is the first time, and you have not yet build the Spotfire images and charts:

1. Clone or update the Spotfire CDK repository
    ```bash
    make git-clone-spotfire-cdk
    ```

2. Build Spotfire container images with Spotfire CDK:
    ```bash
    make docker-build-images
    ```

3. Push Spotfire container images to the OCI registry $REGISTRY:
    ```bash
    make docker-push-images
    ```

4. Package Spotfire Helm charts:
    ```bash
    make helm-pkg-spotfire
    ```

5. Deploy Spotfire using a custom Helm umbrella chart:
    ```bash
    make helm-deploy-spotfire
    ```

6. Show deployed helm releases in the configured namespace:
    ```bash
    make helm-ls-namespace
    ```

7. Show kubectl resources in the configured namespace:
    ```bash
    make kubectl-ls-namespace
    ```
   **Note**: The Spotfire services will be ready in ~1-5 minutes, depending on your hardware.

8. Show the automatically generated Spotfire admin password:
    ```bash
    make show-spotfire-credentials
    ```
   **Note**: The default Spotfire admin user is 'admin'.

9. Open a browser and point to your Spotfire deployment haproxy external IP address:

   **Note**: By default, this quickstart exposes Spotfire's haproxy service as a LoadBalancer service type in K8s. 
   As an alternative, you can use Ingress to expose that same K8s service to another Load Balancer provided by your cloud service provider.

### Alternative 3: Pick your menu

Just run the steps that you need. 

For example, if you have already built the Spotfire images and charts, and you just want to push them to other OCI registry and deploy Spotfire in your configured k8s cluster, simply run:
```bash
make docker-push-spotfire helm-deploy-spotfire show-spotfire-credentials
```
