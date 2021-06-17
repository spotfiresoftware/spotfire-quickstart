# Build TIBCO Spotfire Automatic Deployment container

## Overview

Follow this instructions if you want to build an "all-in-one" container including the following applications required to run the TIBCO Spotfire Automatic Deployment Quick-start templates.

- Python
- Terraform
- Ansible
- Azure cli

## Preparation

1. Build the container

   ~~~
   docker build --rm --tag spotfire-autodeploy-buster-slim .
   ~~~

2. Review and modify as needed the `config.env` variables to fit to your environment

   ~~~
   . ./config.env
   ~~~

3. For easy of use, create an alias to run the container. 

   ~~~
   alias tsa="docker run --rm -it \
      -v '${SANDBOX_REPO_PATH}':'/home/spotfire/sandbox':rw \
      -v '${AZURE_CRED_PATH}':'/home/spotfire/.azure/':rw \
      -e SSH_PUB_KEY=\"$(cat ~/.ssh/id_rsa.pub)\" \
      -e SSH_PRIV_KEY=\"$(cat ~/.ssh/id_rsa)\" \
      --name tsa spotfire-autodeploy-buster-slim"
   ~~~

   *Note: The containers are ephemeral, therefore we fetch the SSH keys from the host, and we store the azure credentials in the host.*

4. Check the alias execution and display usage.

   ~~~
   tsa
   ~~~

## Usage

For usage description, see the Usage section within [Automatic Deployment of Spotfire Platform on Azure](../../../terraform/azure/README.md).