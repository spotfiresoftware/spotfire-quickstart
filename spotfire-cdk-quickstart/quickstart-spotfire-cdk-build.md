# Spotfire Quick start: Build (Makers)

## Overview

This quick start guide describes how to **BUILD** Spotfire container images and Helm charts.

This is a short step by step Spotfire CDK quick start: like the Spotfire CDK, but in short format, with compressed steps and explanations.

For more detailed information, see the [Cloud Deployment Kit for Spotfire®](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main/).

## Prerequisites

- You have a Linux host for building the artifacts (aka the launcher).
- You have the following installed command tools in your launcher: `make`, `docker`, `kubectl`, `helm`, `jq`.

## Procedure

Deploy Spotfire steps:
1. Launcher setup
2. Build Spotfire container images
3. Build Spotfire Helm charts

### Launcher setup

1. Clone the [Cloud Deployment Kit for Spotfire](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit) repo in your launcher host::
    ```bash
    mkdir -p src/spotfire
    cd src/spotfire
    git clone https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit.git
    cd spotfire-cloud-deployment-kit
    ```
2. Download the Spotfire software and copy the files into `<this_repo_root>/containers/downloads/<spotfire_version>`.

   **Note**: See the  [Spotfire installation packages](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main/containers#prerequisites) for more information.

### Build Spotfire container images

1. Build the Spotfire container images:
    ```bash
    cd <spotfire_cdk_repo_root>/containers
    make build DOWNLOADS_DIR=downloads/14.0.0
    ```
   **Note**: This step takes ~5min.

2. List the built Spotfire container images:
    ```bash
    docker images | grep spotfire
    ```
3. Push the images to your private registry
    ```bash
    export REGISTRY=127.0.0.1:32000
    make push
    ```
   **Note**: This step takes ~5min.

### Build Spotfire Helm charts

1. Build the Spotfire Helm charts:
    ```bash
    cd ../helm
    make
    ```
2. List the built Spotfire Helm charts:
    ```bash
    ls -l packages/
    ```

## Next steps

Now you can continue with the [Quick start: Deploy](quickstart-spotfire-cdk-deploy.md).
