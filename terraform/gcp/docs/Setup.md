# Install the Configuration Management applications

## Overview

Follow these instructions if you want to install the following applications in your server:

- Terraform
- Ansible
- Google Cloud CLI

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
4. Using the Google Cloud Resource Manager modules requires having specific Google Cloud SDK modules installed on the host running Ansible:
   ```bash
   ansible-galaxy collection install google.cloud
   pip install --upgrade requests google-auth
   ```

For more details, see the [Ansible Google Cloud Platform Guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html).

## Install Google Cloud CLI

For installing Google Cloud CLI, we follow Google's official procedure: [Installing the latest Cloud SDK](https://cloud.google.com/sdk/docs/quickstart#deb).

For Debian/Ubuntu:
```bash
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

**Note**: Check Google's instructions for other supported OS.

### Configure Google Cloud CLI

To initialize the Cloud SDK:
```bash
gcloud init
```

For more details, see [Initializing the Cloud SDK](https://cloud.google.com/sdk/docs/quickstart).

**Note**: We recommend using a [Google IAM service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts).