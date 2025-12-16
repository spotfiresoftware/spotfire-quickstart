# Deploy Spotfire on a Kubernetes cluster using the Spotfire CDK

This `Makefile` provides an example for easier reference and smother quickstart for implementing a Spotfire CI/CD pipeline automation using the [Spotfire Cloud Deployment Kit (CDK)](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main).

For modifying this Makefile to a specific Spotfire CDK release, see: https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main

**Note**: If you prefer, you can just use the Spotfire CDK directly.
This is just a simple wrapper for easier quickstart.

## Prerequisites

- You have downloaded the Spotfire installation packaged and copied them into your launcher. See [Spotfire software repository](../swrepo/build/README.md)
- A **Linux host** with admin permissions to install and use the tools.
  You can use a bare metal installed server or a virtual machine.
  In this quickstart we will refer to it as "_the launcher_".
- You have the following installed command tools in your launcher: `make`, `docker`, `kubectl`, `helm`, `jq`.
- A working Kubernetes cluster.

**Note**: All the examples and scripts in this quickstart use a Debian/Ubuntu host as the launcher, but you can use any Linux distro.
See the corresponding vendor instructions and adapt the quickstart as required for using other operating systems.

## Launcher setup

1. Clone this repo into a folder in your launcher host:
    ```bash
    mkdir -p src/spotfire
    cd src/spotfire
    git clone https://github.com/spotfiresoftware/spotfire-quickstart
    ```
   **Note**: You can skip this step if you have already done that for creating a EKS, AKS or GKE cluster. 

2. Download the Spotfire software and copy the files into `<this_repo_root>/swrepo/build/<spotfire_version>`.
   
   **Note**: See the [Spotfire software repository](../swrepo/build/README.md) for more information.

3. Move to the `<this_repo_root>/spotfire-cdk-quickstart` directory:
    ```bash
    cd <this_repo_root>/spotfire-cdk-quickstart/
    ```

## Procedure

### Preparation

Read and, if needed, configure the file [variables.env](./variables.env).

Below are 3 alternative methods for deploying Spotfire on K8s using this Makefile.
    a) A single command for everything. This is the easiest once you have done it before, and want to repeat it quickly.
    b) A step by step method. Recommended for the first time, or if you want to understand the steps.
    c) Pick your menu. Advanced, once you know what you need.

### Alternative 1: TL;DR

Just run:
```bash
make all
```

**Note**: This is only recommended after you are familiar with the step by step method below.

### Alternative 2: Step by step

If this is the first time, and you have not yet build the Spotfire images and charts, you need to run steps 1-5. Further times, you can start from step 5.

1. Clone or update the Spotfire CDK repository
    ```bash
    make git-clone-spotfire-cdk
    ```

2. Build Spotfire container images with Spotfire CDK:
    ```bash
    make docker-build-images
    ```

3. Push Spotfire container images to the OCI registry $REGISTRY_SERVER:
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
    make helm-ns-ls
    ```

7. Show kubectl resources in the configured namespace:
    ```bash
    make kubectl-ns-get-all
    ```
   **Note**: The Spotfire services will be ready in ~1-5 minutes, depending on your hardware.

8. Show the automatically generated Spotfire admin password:
    ```bash
    show-spotfire-admin-credentials
    ```
   **Note**: The default Spotfire admin user is 'admin'.

9. Access the Spotfire web interface (it usually takes ~2-5 minutes for the Load Balancer to be ready):
    ```bash
    make show-lb
    ```

   **Note**: By default, this quickstart exposes Spotfire's haproxy service as a LoadBalancer service type in K8s.
   As an alternative, you can use Ingress to expose that same K8s service to another Load Balancer provided by your cloud service provider.

### Alternative 3: Pick your menu

Just run the steps that you need. 

For example, if you have already built the Spotfire images and charts, and you just want to push them to other OCI private registry and deploy Spotfire in your configured k8s cluster, simply run:
```bash
make docker-push-images helm-deploy-spotfire show-spotfire-admin-credentials
```
