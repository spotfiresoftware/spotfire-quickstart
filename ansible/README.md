# Automatic Deployment of Spotfire Platform on using Ansible

## Overview

This **Spotfire QuickStart** example shows how to automatically deploy the Spotfire Platform on your defined infrastructure using the most common configuration management tool: [Ansible](https://github.com/ansible/ansible) .

**Note**: The purpose of this quickstart example is to provide a starting point for automatic deployment of Spotfire in any environment. This quickstart example can be easily extended and customized.

**Note**: This quickstart example has been verified with Spotfire 12.x series, but it may work for previous Spotfire versions with minimal modifications.

### Which kind of Spotfire deployment is deployed by this quickstart example?

This example follows the [Basic installation process for Spotfire
](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/basic_installation_process_for_spotfire.html) from the [Spotfire® Server and Environment - Installation and Administration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/basic_installation_process_for_spotfire.html).

This basic installation will deploy the following components:
- Spotfire Server(s) (using Azure Linux virtual machine(s))
- Spotfire Web Player(s) (using Azure Windows Linux virtual machine(s))
- Spotfire database (using Azure Database for PostgreSQL)

## Prerequisites

1. You need to **download the Spotfire software** (available from [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep)).
   - Spotfire Server: Linux rpm package (`spotfireserver-<version>.rpm`)
   - Spotfire node manager: Windows installation package (`nm-setup.exe`)
   - Spotfire Server client packages: Distribution package (`Spotfire.Dxp.sdn`)
   - Spotfire database scripts

2. You need a **Debian/Ubuntu** host with admin permissions to execute the automatic deployment. 
   You can use a bare metal installed server, a virtual machine or WSL on Windows. Let's call it "the launcher".

## Setup

1. Clone this repo into a folder in your launcher:
   ```bash
   git clone https://github.com/spotfiresoftware/spotfire-quickstart
   ```

2. Download the Spotfire software and copy the files into `<this_repo_root>/swrepo/build`:
   - spotfireserver-<version>.x86_64.tar.gz
   - spotfirenodemanager-<version>.x86_64.tar.gz
   - Spotfire.Dxp.sdn

3. You need to install the required configuration management applications. You can either:

   a) Follow the [Install the Configuration Management applications](docs/Setup.md) instructions to manually install and configure `[Azure CLI|AWS CLI|GCP CLI]`, plus Terraform and Ansible in your launcher.
   b) Follow the [Build spotfire-autodeploy container](../../autodeploy/dockers/spotfire-autodeploy-buster-slim/README.md) (EXPERIMENTAL) instructions to build an "all-in-one" container including `[Azure CLI|AWS CLI|GCP CLI]`, plus Terraform and Ansible configuration management applications.

4. Generate your SSH keys (if you do not have them already):
    ```bash
    ssh-keygen -t rsa -C "spotfire-deploy" -f ~/.ssh/id_rsa -N ""
    ```

## Usage

### Configure the target environment

You can edit the file `inventory/hosts` to reflect your **infrastructure** (servers, ip addresses,...).

You can edit the file `config/vars.yml` to configure your **Spotfire application settings** (like the Spotfire version, config-tool, and web admin credentials,...).

### Deploy the software into the target environment

Deploy Spotfire to your custom infrastructure (customize  `inventory/hosts` example file) using:
```bash
ansible-playbook -i hosts.yml --extra-vars @config/vars.yml site.yml
```

You can also deploy Spotfire into your existing cloud service provider infrastructure using:
```bash
ansible-playbook -i inventory/host_groups_azure_rm.yml --extra-vars @config/vars.yml site.yml
```

You can limit the Spotfire deployment to a server type (for example, after adding new infrastructure or for applying new configuration) using:
```bash
ansible-playbook -i inventory/host_groups_azure_rm.yml --extra-vars @config/vars.yml site.yml --limit sfwp_servers
```

**Note**: For your convenience, there is a `Makefile` that enables you to use the `make` command.
