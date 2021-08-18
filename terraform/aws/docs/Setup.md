# Install the Configuration Management applications

## Overview

Follow these instructions if you want to install the following applications in your server:

* Terraform
* Ansible
* AWS CLI

For easy reference, the official vendor procedures for a Debian/Ubuntu distribution are compiled in this page. 
For other operating systems, please check the specific vendor documentation.

## Install common tools

If you start from a minimal distro, you may need to install some basic common tools.

```
apt-get install -y gnupg software-properties-common curl
```

## Install Terraform

For installing Terraform, we follow Terraform official procedure: [Hashicorp Terraform Debian/Ubuntu install](https://www.terraform.io/docs/cli/install/apt.html). 
See also [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) for instructions for other OS.

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
2. Install Ansible. Note you need at least Ansible 2.8 version for running Ansible Galaxy. 
   Check your version with `ansible --version`.
   ```
   python3 -m pip install 'ansible==2.10.7'
   ```
3. Install general required Ansible collections.
   ```
   ansible-galaxy collection install community.windows
   ```
4. Using the AWS Resource Manager modules requires having specific AWS SDK modules installed on the host running Ansible. 
   For more details, see the [Ansible AWS guide](https://docs.ansible.com/ansible/latest/scenario_guides/guide_aws.html).
   ```
   ansible-galaxy collection install amazon.aws
   sudo pip3 install --user boto3   
   ```

## Install AWS CLI

For installing AWS CLI, we follow AWS's official procedure: [Install the AWS CLI v2 on Linux](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html).

```
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf /tmp/aws
```

### Configure AWS CLI

You need to get your AWS credentials information from the AWS IAM (Identity and Access Management) web console.
It is located under _IAM > Users > [your username] > Security Credentials > Access Keys_. 
You can create new access key there. Remember to save both the access key ID and the secret access key. 

Note: Here we describe how to use a federated AWS account, since it is the preferred method. 
For direct how directly use a non federated AWS account, please refer to AWS documentation.

You need to configure the AWS cli with:

```
aws configure
```

This command will query for your credential details and will generate the `~/.aws/config` and `~/.aws/credentials` files.

You can add your federated account as a profile in your `~/.aws/config` file.
For example, adding `SpotfirePMRole` profile:
```
[default]
region = eu-north-1
output = json

[profile SpotfirePMRole]
role_arn = arn:aws:iam::ACCOUNT_ID:role/SpotfirePowerUser
source_profile = default
```

You could as well add other accounts in your `~/.aws/credentials` file.
For example, adding `anotherUser` account:
```
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_ID

[anotherUser]
aws_access_key_id = ANOTHER_ACCESS_KEY_ID
aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY_ID
```

For more details, see the official documentation [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
For information on AWS IAM roles, see [IAM roles
](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html).

#### Method 1: Exporting assumed role profile

Plus: Simpler method
Minus: Slower method (implies ~5-7 secs extra on each call)

To use your the federated account as an assigned role, you can just export the profile name in your environment: 
```
export AWS_PROFILE=SpotfirePMRole
```

#### Method 2: Exporting assumed role credentials

Plus: Faster
Minus: Needs to be done from time to time due session token timeout

To use your the federated account as an assigned role, you need to fetch the temporal credentials and export them into your environment. 
This can be done in one command with:

```
source <(aws sts assume-role --role-arn arn:aws:iam::ACCOUNT_ID:role/SpotfirePowerUser --profile SpotfirePMRole --role-session-name SpotfirePowerUser \
   | jq -r  '.Credentials | @sh "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n "')
```

Note: This assumed role credentials have an expiration time. 
You need to this from time to time due session token timeout.

You can do that easier with the provided Makefile, so you do not need to remember that syntax:

```
tsa aws-assume-role-env
```

Remember to export the variables from the tsa command output:

```
export AWS_ACCESS_KEY_ID=ASSUMED_ROLE_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=ASSUMED_ROLE_SECRET_ACCESS_KEY_ID
export AWS_SESSION_TOKEN=ASSUMED_ROLE_SESSION_TOKEN
```
