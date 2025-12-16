# Install the Configuration Management applications

## Overview

Follow these instructions if you want to install the following applications in your server:

- Terraform
- Ansible
- Azure CLI

For easy reference, the official vendor procedures for a Debian/Ubuntu distribution are compiled in this page. 
For other operating systems, please check the specific vendor documentation.

## Install common tools

If you start from a minimal distro, you may need to install some basic common tools.

```bash
apt-get install -y gnupg software-properties-common curl
```

## Install Terraform

For installing Terraform, we follow Terraform official procedure: [Hashicorp Terraform Debian/Ubuntu install](https://www.terraform.io/docs/cli/install/apt.html). 
See also [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) for instructions for other OS.

For your convenience, these are the steps:

1. Update your system sources and upgrade packages:
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```
2. Add the HashiCorp key:
   ```bash
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   ```
3. Add the official HashiCorp repository:
   ```bash
   sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   ```
4. Install the Terraform package:
   ```bash
   sudo apt install -y terraform
   ```

For more info on different cloud providers see:
- [Terraform on Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/overview)

## Install Ansible

For installing Ansible, we follow Ansible's official procedure: [Installing Ansible with pip](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip).

For your convenience, these are the steps:

1. Install `pip`, `setuptools` and `wheel` if not already in the system:
   ```bash
   python3 -m pip install --upgrade pip setuptools wheel
   ```
2. Install Ansible: 
   ```bash
   python3 -m pip install ansible
   ```
   **Note**: You need at least Ansible 2.8 version for running Ansible Galaxy. 
   Check your version with `ansible --version`.
3. Install general required Ansible collections:
   ```bash
   ansible-galaxy collection install community.windows
   ```
4. Using the Azure Resource Manager modules requires having specific Azure SDK modules installed on the host running Ansible:
   ```bash
   curl https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt > /tmp/requirements-azure.txt
   python3 -m pip install -r /tmp/requirements-azure.txt
   ansible-galaxy collection install azure.azcollection
   ```

5. Upgrade all installed Ansible collections to the latest version:
    ```bash
    ansible-galaxy collection list | awk '/^[a-z]/ {print $1}' |xargs -r ansible-galaxy collection install --upgrade
    ```

For more details, see the [Ansible Azure guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html).

## Install Azure CLI

For installing Azure CLI, we follow Azure's official procedure: [Install the Azure CLI on Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux).

1. Install Azure CLI:
    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```

2. Sign in to Azure with the Azure CLI, using a device code:
    ```bash
    az login --use-device-code
    ```
   Then, open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal.

   For more info. see [Sign in with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli).

3. After successfully login, the Azure subscription information is displayed in the terminal. Note your Azure's subscription ID and tenant ID.

### Alternative method: Exporting credentials as environment variables (Terraform) 

You can pass the credentials as environment variables.
```bash
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

Another way is to store these variables in a secure file location and import them before using Terraform.
For example:
```bash
. ~/.azure/creds.env
```

See [Azure Provider: Authenticating using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) for more detailed information.

**Note**: To provide Terraform with the credentials' information, you can copy your subscription details into the `provider.tf` file respective fields.
Nevertheless, we recommend not defining these variables into the `provider.tf` file since they could easily be checked into your version control system by mistake.

For more info, see the [Azure CLI cheatsheet](https://learn.microsoft.com/en-us/cli/azure/cheat-sheet-onboarding)