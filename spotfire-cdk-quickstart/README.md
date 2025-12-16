# Spotfire Quickstart on Kubernetes using the Spotfire CDK

## Overview

This **Spotfire QuickStart on Kubernetes** shows how to automatically deploy the [Spotfire platform](https://www.spotfire.com/) on [Kubernetes](https://kubernetes.io/) using the the [Spotfire Cloud Deployment Kit (CDK)](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main).

**Note**: The purpose of this quickstart example is to provide a starting point for automatic deployment of Spotfire.
This quickstart is not for production usage.
This quickstart example can be easily extended and customized for production usage.

**Note**: This quickstart example has been verified with Spotfire 14.6.0 LTS release, but it may work for other Spotfire versions with minimal modifications.

## Which kind of Spotfire environment is deployed by this quickstart example?

You will deploy a complete working Spotfire environment on a existing Kubernetes cluster.

## Prerequisites

- Required **Spotfire** installation packages. You can download them from the [Spotfire Download site](https://www.spotfire.com/downloads).
- A **Linux host** with admin permissions to install and use the tools.
  You can use a bare metal installed server or a virtual machine.
  In this quickstart we will refer to it as "_the launcher_".
- You have the following installed command tools in your launcher: `make`, `docker`, `kubectl`, `helm`, `jq`.
- A working Kubernetes cluster.

**Note**: All the examples and scripts in this quickstart use a Debian/Ubuntu host as the launcher, but you can use any Linux distro.
See the corresponding vendor instructions and adapt the quickstart as required for using other operating systems.

## Alternative methods

Depending on your expertise and your objectives, you can chose between these 3 similar methods:

A. Go to the source, follow the [Spotfire Cloud Deployment Kit (CDK)](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/tree/main) repo.
   Here you will find a lot of useful information, although it might take some time to digest. 

B. A short step by step Spotfire CDK quick start. Using the Spotfire CDK, but in short format, with compressed steps and explanations:
   1. [Quick start: CDK Build](quickstart-spotfire-cdk-build.md)
   2. [Quick start: CDK Deploy](quickstart-spotfire-cdk-deploy.md)

C. A simple Makefile for the Spotfire CDK quick start. Using the Spotfire CDK, just automated with a convenient Makefile. This is the preferred method.
   - [Quick start: CDK Makefile](quickstart-spotfire-cdk-makefile.md)

D. The easier and faster alternative, use the pre-built Spotfire images and charts from the [Spotfire on Kubernetes](spotfi.re/sok). You can go directly to the quickstart there:
   - [Quickstart: Spotfire on Kubernetes Makefile](../spotfire-cdk-quickstart/README.md).
