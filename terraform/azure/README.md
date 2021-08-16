
# Automatic Deployment of Spotfire Platform on Azure using Terraform + Ansible

## Overview

This **Spotfire QuickStart** example shows how to automatically deploy the Spotfire Platform on Azure 
using the 2 most used agnostic configuration management tools: [Terraform](https://www.terraform.io/) and [Ansible](https://github.com/ansible/ansible).

Note: The purpose of this quickstart example is to provide a starting point for automatic deployment of Spotfire in any environment. 
This quickstart example can be easily extended and customized.

Note: This quickstart example has been verified with Spotfire 11.x series, but it may work for previous Spotfire versions with minimal modifications.

### Which kind of Spotfire deployment is deployed by this quickstart example?

This example follows the [Basic installation process for Spotfire]
(https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/basic_installation_process_for_spotfire.html) 
from the [TIBCO Spotfire® Server and Environment - Installation and Administration]
(https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/getting_started.html).

This basic installation will deploy the following components:
- TIBCO Spotfire Server(s) (using Azure Linux virtual machine(s)).
- TIBCO Spotfire Web Player(s) (using Azure Windows Linux virtual machine(s)).
- TIBCO Spotfire database (using Azure Database for PostgreSQL).
- jumphost server(s) to manage application VMs.
- Load balancer (using Azure Application Gateway) (optional *).
- Azure Bastion host to manage Windows servers (optional **).

Note(*): For quick testing purposes you may want to avoid creating an Azure Application Gateway,
since it requires some time (~30 min) to be created in Azure. 
In that case, you need to enable creation of tss public ip address to access the application directly (more details below).

Note(**): You can [connect to a Windows host with RDP using a jumphost](docs/Connect-with-RDP-using-jumphost.md), without the need of a dedicated Azure Bastion host.

The diagram below shows the deployed environment by this Quickstart for TIBCO Spotfire in Azure.

![Spotfire architecture (basic) in Azure](docs/images/spotfire-arch-azure-basic-agw-az.png)

## Prerequisites

1. You need to **download the TIBCO Spotfire software** (available from [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep)).
    - TIBCO Spotfire Server: Linux rpm package (`tss-<version>.rpm`).
    - TIBCO Spotfire node manager: Windows installation package (`nm-setup.exe`).
    - TIBCO Spotfire Server client packages: Distribution package (`Spotfire.Dxp.sdn`).
    - TIBCO Spotfire database scripts.
    
2. You need a **Debian/Ubuntu host** with admin permissions to execute the automatic deployment. 
   You can use a bare metal installed server, a virtual machine or WSL on Windows. 
   In this quickstart we will refer to it as "_the launcher_".

3. Valid **Azure account and credentials**.

Note: In this example we use a Debian/Ubuntu host to run Terraform and Ansible, but you can use any Linux distro. 
See the corresponding vendor instructions for using other operating systems.

## Launcher setup

1. Clone this repo into a folder in your launcher.

   ```
   git clone https://github.com/TIBCOSoftware/spotfire-quickstart
   ```

2. Download the Spotfire software and copy the files into `<this_repo_root>/swrepo/build`

   - tss-<version>.x86_64.rpm
   - nm-setup.exe
   - Spotfire.Dxp.sdn
   - scripts/

3. You need to install the required configuration management applications. 
   
   There are two main alternatives for running the quickstart:

   - **Using a VM (or WSL)**: 
   Follow the [Install the Configuration Management applications](docs/Setup.md) instructions to manually install and configure Azure CLI, Terraform and Ansible in your launcher.
   
     For your convenience, there is a `Makefile` that enables you to use Terraform and Ansible commands via the `make` command from the Terraform templates folder (`<this_repo_root>/terraform/azure`).
     This way, you do not need to memorize the syntax, and the commands are much simpler.
     
     For simplicity, you can create an alias:
     ```
     cd <this_repo_root>/terraform/azure
     alias tsa="make --directory $PWD"
     ```

     Note: If you want to know about the details and understand what is going under the hood,
you can check the [Detailed instructions](docs/Detailed-instructions.md).

   - **Using containers** (experimental): 
   Follow the [Build spotfire-autodeploy container](../../autodeploy/dockers/spotfire-autodeploy-buster-slim/README.md) instructions to build an "all-in-one" container including Azure CLI, Terraform and Ansible configuration management applications.

4. Generate SSH keys (if you do not have them already).

   ```
   ssh-keygen -t rsa -C "spotfire-deploy" -f ~/.ssh/id_rsa -N ""
   ```

## Usage

The deployment life cycle consists of these steps:

1. Prepare your launcher host
2. Configure the target environment
3. Review the planned changes 
4. Create the required infrastructure (with Terraform)
5. Deploy the Spotfire software (with Ansible)
6. Destroy the created environment

### Prepare your launcher host

1. Initiate your environment (only required the first time).

   ~~~
   tsa init
   ~~~

2. If not already done, sign in into Azure with the Azure CLI. 
   See the Azure CLI instructions within [Install the applications](docs/Setup.md) for more details.

   ~~~
   tsa azlogin
   ~~~

### Configure the target environment

3. You can customize the **deployment environment** by editing the file `terraform.env`.

   Note: You need to use a different `TF_WORKSPACE` for applying different environments for the same location.

4. You can customize the **infrastructure settings** like number of instances or sizing, by modifying the `terraform.env`, `variables.tfvars` and `vars-size-XS.tfvars`. 
   Open the files for listing the existing configuration variables, description and documentation links.

   Note: You need to use a different `prefix` in `variables.tfvars` for applying multiple environments using the same account.

   Note: You need to modify the `admin_address_prefixes` and `web_address_prefixes` variables,
   so you allow infra admin and end user access to the environment from your respective selected address blocks 
   (you can find your public ip address for example in https://whatismyipaddress.com/).

   Note: We may decide to not create an Azure Application Gateway, or an Azure Bastion (it takes some time, money and it is not very interesting for small test environments). 
   Check in `vars-size-XS.tfvars` the variables that control *resource creation and sizing*. 
   Note: If you choose to not creating an Azure Application Gateway, you need to choose to create public ip addresses for yor tss hosts.

   Note: The `vars-size-XS.tfvars` settings overrides `variables.tfvars` settings.

5. If you want to change **Spotfire application settings** (like the Spotfire version, config-tool and web admin credentials,...), review and edit the file `ansible/config/vars.yml`.

   Note: The variables in `ansible/config/vars.yml` are used as defaults and may be overriden by previous configuration files.

6. Verify the planed infrastructure changes before applying them.

   ~~~
   tsa plan
   ~~~

### Create the required infrastructure (Terraform)

7. If you agree with the planned changes, apply them to create the infrastructure.

   ~~~
   tsa apply
   ~~~

   Note: This step may take 15-30 minutes depending on the sizing.

### Deploy the Spotfire software (Ansible)

8. Once the infrastructure is in place, you can deploy the software.

   ~~~
   tsa deploy
   ~~~

### Resize or reconfigure the created environment

9. You can resize or change your system's configuration by editing again the named configuration files and repeating steps 4-8.

   ~~~
   tsa plan
   tsa apply
   tsa deploy
   ~~~
   
   Note: You can use similar deploy command as previous to limit the deployment to a specific type of server.
   For example if you only increased the number of VM instances for the Web Player servers you can just deploy those with:

   ~~~
   tsa deploy ANSIBLE_EXTRA_ARGS="--limit wp_servers"
   ~~~

### Destroy the created environment

10. Remember to destroy the environment when you are not going to use it to avoid unneeded costs.

   ~~~
   tsa destroy
   ~~~

## Use your environment

1. You can find details for the created environment using.

   ~~~
   tsa show-hosts
   ~~~

   There are more `show-*` command aliases preconfigured to retrieve basic information on your system.
   Run `tsa` without arguments to see the command help.

2. Open the TIBCO Spotfire server web UI: 
    - If you chose to create public ip addresses for you tss server(s), you can connect to the tss using `http://<your-tss-ip-address>:8080`.
    - If you chose to create an Azure Application Gateway, you can connect to the tss cluster using `http://<your-azure-app-gw-ip-address>`.

## What to do next

There are further ways to customize this setup:

- Enable SSL connection
- Add other Spotfire services
- Use multiple Azure regions
- etc.

Please, see the [TIBCO Spotfire® Server and Environment - Installation and Administration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/getting_started.html) documentation for details on specific administration procedures.

