# Install the Configuration Management applications

## Overview

Follow this instructions if you want to install the following applications in your server:

* Terraform
* Ansible
* Azure CLI

For easy reference, the official vendor procedures for a Debian/Ubuntu distribution are compiled in this page. For other operating systems, please check the specific vendor documentation.

## Install common tools

If you start from a minimal distro, you may need to install some basic common tools.

```
apt-get install -y gnupg software-properties-common curl
```

## Install Terraform

For installing Terraform, we follow Terraform's official procedure: [Hashicorp Terrafom Debian/Ubuntu install](https://www.terraform.io/docs/cli/install/apt.html). See also [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) for instructions for other OS.

For your convenience, these are the steps:

1. Update your system sources and upgrade packages.
   ```
   sudo apt-get update && sudo apt-get upgrade -y
   ```
2. Add the HashiCorp key.
   ```
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   ```
3. Add the official HashiCorp repository.
   ```
   sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   ```
4. Install the Terraform package.
   ```
   sudo apt install -y terraform
   ```

## Install Ansible

For installing Ansible, we follow Ansible's official procedure: [Installing Ansible with pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

For your convenience, these are the steps:

1. Install `pip`, `setuptools` and `wheel` if not already in the system.
   ```
   python3 -m pip install --upgrade pip setuptools wheel
   ```
2. Install Ansible. Note you need at least Ansible 2.8 version for running Ansible Galaxy. Check your version with `ansible --version`.
   ```
   python3 -m pip install 'ansible==2.10.7'
   ```
3. Install general required Ansible collections.
   ```
   ansible-galaxy collection install community.windows
   ```
4. Using the Azure Resource Manager modules requires having specific Azure SDK modules installed on the host running Ansible. For more details, see the [Ansible Azure guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html).
   ```
   curl https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt > /tmp/requirements-azure.txt
   python3 -m pip install -r /tmp/requirements-azure.txt
   ansible-galaxy collection install azure.azcollection
   ```

## Install Azure CLI

For installing Azure CLI, we follow Azure's official procedure: [Install the Azure CLI on Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux).

1. Install Azure CLI
    ```
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```
2. Sign in to Azure with the Azure CLI
    ```
    az login
    ```
   If the CLI can open your default browser, it will do so and load an Azure sign-in page.

   Otherwise, open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal.

3. After successfully login, the Azure subscription information is displayed in the terminal. Note your Azure's subscription ID and tenant ID.

### Terraform Configuration

To provide Terraform with the Azure credentials information, you can copy your Azure's subscription ID and tenant ID into the `provider.tf` file respective fields.

Nevertheless, we'd recommend not defining these variables into the `provider.tf` file since they could easily be checked into Source Control.

The recommended alternative is to pass these credentials as Environment Variables, for example:
```
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```
As an alternative, you can store these variables in a secure file location and import them before using Terraform. For example:
```
. ~/.azure/creds.env
```

See [Azure Provider: Authenticating using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) for more detailed information.