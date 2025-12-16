# Spotfire Quickstart on Kubernetes using the Spotfire on Kubernetes (SoK)

## Overview

This **Spotfire QuickStart on Kubernetes** shows how to automatically deploy the [Spotfire platform](https://www.spotfire.com/) on [Kubernetes](https://kubernetes.io/) using the the [Spotfire on Kubernetes (SoK)](https://spotfi.re/sok).

**Note**: The purpose of this quickstart example is to provide a starting point for automatic deployment of Spotfire.
This quickstart is not for production usage.
This quickstart example can be easily extended and customized for production usage.

**Note**: This quickstart example has been verified with Spotfire 14.6.0 LTS release, but it may work for other Spotfire versions with minimal modifications.

## Which kind of Spotfire environment is deployed by this quickstart example?

You will deploy a complete working Spotfire environment on a existing Kubernetes cluster.

## Prerequisites

- Valid credentials for the Spotfire on Kubernetes registry. See [Accessing the Spotfire OCI Registry
  ](https://docs.tibco.com/pub/sf-kbn/4.0.0/doc/html/user-guide/quick-start/spotfire-oci-registry.html) .
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
    cd <this_repo_root>/spotfire-sok-quickstart/
    ```

## Procedure

1. Check out and modify the [`variables.env`](./variables.env) file.
There you can set your Spotfire OCI registry credentials and other variables as required.

2. Create the Kubernetes namespace and the OCI registry secret:
    ```bash
    make kubectl-ns-create-oci-registry-secret
    ```
3. Deploy Spotfire on Kubernetes using the Spotfire on Kubernetes (SoK) Helm charts:
    ```bash
    make helm-deploy-spotfire-sok
    ```
4. Verify the deployed Spotfire on Kubernetes pods:
    ```bash
    make kubectl-ns-get-all
    ```
5. Show the Spotfire web admin credentials:
    ```bash
    make show-spotfire-admin-credentials
    ```
6. Access the Spotfire web interface (it usually takes ~2-5 minutes for the Load Balancer to be ready):
    ```bash
    make show-lb
    ```

**Note**: By default, this quickstart exposes Spotfire's haproxy service as a LoadBalancer service type in K8s.
As an alternative, you can use Ingress to expose that same K8s service to another Load Balancer provided by your cloud service provider.