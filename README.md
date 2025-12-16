
# Quickstart for Spotfire®

## Introduction

The **Quickstart for Spotfire®** provides a reference and starting point for automatic deployment of [Spotfire® platform](https://www.spotfire.com/) anywhere: on premises or on any cloud provider, 
using different common configuration management tools.

This repository does not include any Spotfire® software or any other third party software.
This repository contains quick guides, templates, configuration examples and scripts.

These quickstart examples can be easily extended and customized.

These quickstart examples have been validated with the Spotfire version(s) indicated on each quickstart. 
They might work for other Spotfire versions with some modifications.

Have fun !!!

Quickstarts:

- Deploy Spotfire on Virtual Machines (using installation packages):
  - [Spotfire Quickstart on Amazon EC2 instances](terraform/aws/README.md)
  - [Spotfire Quickstart on Azure Virtual Machines](terraform/azure/README.md)
  - [Spotfire Quickstart on Google Compute Engine instances](terraform/gcp/README.md)

- Deploy Spotfire on K8s (using containers images and Helm charts):
  - [Spotfire Quickstart on Amazon Elastic Kubernetes Service (EKS)](terraform-k8s/aws-eks/README.md)
  - [Spotfire Quickstart on Azure Kubernetes Service (AKS)](terraform-k8s/azure-aks/README.md)
  - [Spotfire Quickstart on Google Kubernetes Engine (GKE)](terraform-k8s/google-gke/README.md)

Note that, for deploying Spotfire on any Kubernetes cluster, you have 2 options:

1. The recommended method is using the pre-built Spotfire images and charts from the [Spotfire on Kubernetes (SoK)](https://spotfi.re/sok).
2. You can also build the Spotfire container images and charts using the recipes from the [Spotfire Cloud Deployment Kit (CDK)](https://spotfi.re/cdk).

The quickstarts above provide the guidance and option to use either of these options.

Stay tuned, more quickstarts coming soon !!!

# Licenses

This project is licensed under the [BSD-3-Clause license](LICENSE).

## Spotfire software

When you use this project to deploy Spotfire on bare metal, VMs or container images, you fetch and use Spotfire software developed at
[Cloud Software Group, Inc.](https://www.cloud.com/).
The Spotfire software will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).
